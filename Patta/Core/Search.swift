import Foundation
import SwiftUI

struct Search: View {
    
    @State private var showTaskSheet = false
    @State private var navPath: [PetRoute] = []
    
    @Environment(TaskViewModel.self) private var taskViewModel
    
    @Environment(PetViewModel.self) private var petViewModel
    
    @Environment(SearchViewModel.self) private var searchViewModel
    
    private let petColumns = [
        GridItem(.adaptive( minimum: 150, maximum: 150 ), spacing: 12)
    ]
    
    var body: some View {
        @Bindable var search = searchViewModel
        
        ScrollView {
            LazyVStack(alignment: .leading, spacing: 16) {
                if searchViewModel.isQueryEmpty {
                    ContentUnavailableView("O que você procura?", systemImage: "magnifyingglass", description: Text("Pesquise por pets ou tarefas."))
                    .frame(maxWidth: .infinity)

                } else if searchViewModel.hasNoResults {
                    ContentUnavailableView("Nenhum resultado", systemImage: "magnifyingglass",description:
                                            Text(
                            """
                            Nenhum resultado para \
                            "\(searchViewModel.treatedQuery)".
                            """
                        ))
                    .frame(maxWidth: .infinity)

                } else {
                    if !searchViewModel.filteredTasks.isEmpty {
                        Text("Tarefas")
                            .font(.headline)

                        ForEach(searchViewModel.filteredTasks) { task in
                            LineTask(task: task,onOpenDetails: {
                                    taskViewModel.prepareToEdit(task)
                                    showTaskSheet = true
                                },
                                onComplete: {
                                    taskViewModel
                                        .toggleTaskCompletion(task)
                                }
                            )
                            .frame(maxWidth: .infinity)
                        }
                    }

                    if !searchViewModel.filteredPets.isEmpty {
                        Text("Pets")
                            .font(.headline)
                            .padding(.top, 8)

                        LazyVGrid(columns: petColumns, alignment: .center,spacing: 12) {
                            ForEach(searchViewModel.filteredPets) { pet in
                                NavigationLink {
                                    EditPetView(pet: pet, viewModel: petViewModel, navPath: $navPath, isDismiss: true)
                                } label: {
                                    PetCard(pet: pet, viewModel: petViewModel)
                                    .frame(width: 150)
                                }
                                .buttonStyle(.plain)
                            }
                        }
                        .frame(maxWidth: .infinity)
                    }
                }
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 8)
        }
        .background {
            Color(.background)
                .ignoresSafeArea()
        }
        .searchable(text: $search.query ,prompt: "Pets e tarefas" )
        .searchDictationBehavior(.inline(activation: .onSelect))
        
        .sheet(isPresented: $showTaskSheet) {
            NavigationStack {
                TaskSheet()
            }
        }
        .navigationTitle("Pesquisar")
        .onAppear {
            taskViewModel.loadTasks()
        }
    }
}
