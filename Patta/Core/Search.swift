

import SwiftUI
import CoreData

struct Search: View {
    @State var query: String = ""
    @Environment(\.managedObjectContext) private var viewContext
    @FetchRequest(
        entity: Pet.entity(),
        sortDescriptors: [NSSortDescriptor(keyPath: \Pet.name, ascending: true)],
        
    ) var pets: FetchedResults<Pet>
    @FetchRequest(
        entity: Task.entity(),
        sortDescriptors: [NSSortDescriptor(keyPath: \Task.title, ascending: true)],
        
    ) var tasks: FetchedResults<Task>
    
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
                    Text(search)
                }
                
                
                if filteredSearch.isEmpty && !query.isEmpty {
                    Text("Nenhum resultado com \"\(query)\" foi encontrado")
                }
                        
            }.searchable(text: $query)
            .searchDictationBehavior(.inline(activation: .onSelect))
        }.navigationTitle("Pesquisar")
            
    }
}

#Preview {
    let context = NSManagedObjectContext(concurrencyType: .mainQueueConcurrencyType)
    NavigationStack{
        Search()
            .environment(\.managedObjectContext, context)
    }
    
}

