

import SwiftUI

struct Search: View {
    @State var query: String = ""
        var task: [String] = ["comida","passear", "banho", "tosa"]
        
        var namePets: [String] = ["Goku", "Nami", "Totó", "Kratos", "Saitama"]
        
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
        
        var filteredSearch: [String] {
            let allItems = task + namePets
            let filter = allItems.filter {$0.localizedCaseInsensitiveContains(query)}
            
            return filter.sorted { item1, item2 in
                sortedFilter(item1: item1, item2: item2)
            }
        }
    
    public var body: some View {
        VStack{
            Text("Pesquisar:")
                .font(.title)
            NavigationStack{
                        
                List{
                    ForEach(filteredSearch, id: \.self) { search in
                        Text(search)
                    }
                    
                    if filteredSearch.isEmpty && !query.isEmpty {
                        Text("Nenhum resultado com \"\(query)\" foi encontrado")
                    }
                            
                }.searchable(text: $query)
                .searchDictationBehavior(.inline(activation: .onSelect))
            }
        }
    }
}

#Preview {
    Search()
}

/*
 Obsv para po grupo: O código contém uma aplicação do sistema de busca
 para isso ele usa a .searcheable junto para filtrar as palavras que vão aparecer na tela como um outro algoritimo que procura as palavras que começam com o que você escreveu na tabbar
    a função localizedCaseInsensitiveContains permite localizar com case sensitive
 
 
 */
