//
//  TaskView.swift
//  Patta
//
//  Created by Paulo Eduardo Barbosa da Silva on 17/08/26.
//

import SwiftUI


struct TaskView: View {
    @Environment(TaskViewModel.self) private var viewModel
    @Environment(TaskListStore.self) private var taskListStore
    @Environment(PetListStore.self) private var petListStore
    
    @State private var showTaskSheet: Bool = false
    @State var selectedDate = Date()
    @State var selectedPet: PetModel?
    @State var selectedTab = 0
    
    private func filteredByDateAndPet(_ source: [TaskModel] ) -> [TaskModel] {
        let calendar = Calendar.current
        
        return source.filter { task in
            guard let taskDate = task.date else {
                return false
            }
            
            guard calendar.isDate(taskDate, inSameDayAs: selectedDate) else {
                return false
            }
            
            guard let selectedPet else {
                return true
            }
            
            return task.appliesToAllPets || task.pet?.id == selectedPet.id
        }
    }
    
    private var pendingTasks: [TaskModel] {
        let pending = taskListStore.tasks.filter { !$0.isCompleted}.sorted { ($0.date ?? .distantFuture) < ($1.date ?? .distantFuture)}
        return filteredByDateAndPet(pending)
    }
    
    private var completedTasks: [TaskModel] {
        let completed = taskListStore.tasks.filter { $0.isCompleted}.sorted{ ($0.completedAt ?? .distantPast) > ($1.completedAt ?? .distantPast)}
        return filteredByDateAndPet(completed)
    }
    
    private var isPetFilterActive: Bool {
        selectedPet != nil
    }
    
    private var petFilterColor: Color {
        PetColorPalette.color(for: selectedPet?.color)
    }
    
    private var petFilterButton: some View {
        Menu {
            Picker("Pets", selection: $selectedPet) {
                Text("Todos")
                    .tag(nil as PetModel?)
                
                ForEach(petListStore.pets) { pet in
                    Text(pet.name)
                        .tag(Optional(pet))
                }
            }
            .pickerStyle(.inline)
        } label: {
            Label("Filtrar",systemImage: isPetFilterActive ? "pawprint.fill" : "pawprint")
                .labelStyle(.titleAndIcon)
                .foregroundStyle(isPetFilterActive ? petFilterColor : Color.primary)
                .padding(6)
        }
        .menuStyle(.button)
        .buttonStyle(.plain)
        .tint(isPetFilterActive ? petFilterColor : Color.primary)
    }
    
    var body: some View {
        VStack {
            WeekCalendar(selectedDate: $selectedDate)
            
            
            Picker("Tarefas agendadas", selection: $selectedTab) {
                Text("Pendentes")
                    .tag(0)
                Text("Concluídas")
                    .tag(1)
            }
            .pickerStyle(.segmented)
            
            
            switch selectedTab {
            case 0:
                PendingTasks(tasks: pendingTasks)
                
            case 1:
                CompletedTasks(tasks: completedTasks)
                
            default:
                PendingTasks(tasks: pendingTasks)
            }
        }
        .padding(.horizontal,24)
        .background {
            Color(.background)
                .ignoresSafeArea()
        }
        .navigationTitle("Tarefa")
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                petFilterButton
            }
            
            ToolbarItem(placement: .navigationBarTrailing) {
                Button {
                    viewModel.prepareNewTask()
                    showTaskSheet = true
                } label: {
                    Image(systemName: "plus")
                        .foregroundStyle(.white)
                }.buttonStyle(.glassProminent)
            }
        }
        .sheet(isPresented: $showTaskSheet) {
            TaskSheet()
        }
        .onAppear {
            viewModel.loadTasks()
        }
        .alert("Não foi possível concluir a operação", isPresented: Binding(
            get: {
                viewModel.errorMessage != nil
            },
            set: { isPresented in
                if !isPresented {
                    viewModel.errorMessage = nil
                }
            }
        ))
        {
            Button("OK", role: .cancel) {}
        } message: {
            Text(viewModel.errorMessage ?? "")
        }
    }
}

