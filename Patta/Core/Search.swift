

import SwiftUI
import CoreData




struct Search: View {
    @State var query: String = ""
    @Environment(\.managedObjectContext) private var viewContext
    @Environment(TaskViewModel.self) private var viewTaskModel
    @Environment(PetViewModel.self) private var viewModel: PetViewModel
    
    @State private var navPath: [PetRoute] = []
    @State private var selectedPet: Pet?
    @State private var showEditPet = false
   
    @FetchRequest(
        entity: Pet.entity(),
        sortDescriptors: [NSSortDescriptor(keyPath: \Pet.name, ascending: true)],
        
    ) var pets: FetchedResults<Pet>
    @FetchRequest(
        entity: Task.entity(),
        sortDescriptors: [NSSortDescriptor(keyPath: \Task.title, ascending: true)],
        
    ) var tasks: FetchedResults<Task>
    
    @State var showTaskSheet: Bool = false
    @State var showPetSheet: Bool = false
    
    var allTasks: [Task] {
        var items: [Task] = []
        for task in tasks {
            items.append(task)
        }
        return items
    }
    var allPets: [Pet] {
        var items: [Pet] = []
        for pet in pets {
            items.append(pet)
        }
        return items
    }
    
    
    var allTasksTitle: [String] {
        var items: [String] = []
        for task in tasks {
            if let name = task.title {
                items.append(name)
            }
        }
        return items
    }
    
    var allPetsName: [String] {
        var items: [String] = []
        for pet in pets {
            if let name = pet.name {
                items.append(name)
            }
        }
        return items
    }
    
 
    
    
    func sortedFilter(item1: String, item2: String)-> Bool {
        let item1StartsWith = item1.localizedCaseInsensitiveContains(query) && item1.hasPrefix(query.lowercased())
        let item2StartsWith = item2.localizedCaseInsensitiveContains(query) && item2.hasPrefix(query.lowercased())
        
        
        if !item1StartsWith && !item2StartsWith {
            return item1.localizedCaseInsensitiveCompare(item2) == .orderedAscending
        }
        if !item1StartsWith && item2StartsWith {
            return false
        }
        return true
    }
    
    var allItems: [String] {
        var items: [String] = []
        
        for pet in pets {
            if let name = pet.name {
                items.append(name)
            }
        }
       
        for task in tasks {
            if let name = task.title {
                items.append(name)
            }
        }
        
        return items
    }
        
    var filteredSearch: [String] {
        let filter = allItems.filter {$0.localizedCaseInsensitiveContains(query)}
        
        return filter.sorted { item1, item2 in
            sortedFilter(item1: item1.lowercased(), item2: item2.lowercased())
        }
    }
    

    public var body: some View {
        NavigationStack{
            Text("Aqui você encontra tudo que precisar!")
                .multilineTextAlignment(.leading)
            List{
                ForEach(filteredSearch, id: \.self) { search in
                    if allTasksTitle.contains(search) {
                        Button {
                            allTasks.forEach { task in
                                if task.title == search {
                                    viewTaskModel.prepareToEdit(task)
                                }
                            }
                            showTaskSheet.toggle()
                        } label: {
                            LineSearch(search: search + " Task")
                        }
                    }
                    if allPetsName.contains(search) {
                        NavigationLink(destination: {
                            if let pet = allPets.first(where: { $0.name == search }) {
                                EditPetView(
                                    pet: pet,
                                    viewModel: viewModel,
                                    navPath: $navPath
                                )
                            }
                        }) {
                            Text(search + " Pet")
                        }.foregroundStyle(.accent)
                    }
    
                    
                }
                
                
                if filteredSearch.isEmpty && !query.isEmpty {
                    Text("Nenhum resultado com \"\(query)\" foi encontrado")
                }
                
                
                        
            }.searchable(text: $query)
            .searchDictationBehavior(.inline(activation: .onSelect))
            .sheet(isPresented: $showTaskSheet) {
                NavigationStack{
                    TaskSheet()
                }
            }
            
        }.navigationTitle("Pesquisar")
            
        
            
    }
}

