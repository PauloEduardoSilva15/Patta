//
//  LineSearch.swift
//  Patta
//
//  Created by Paulo Eduardo Barbosa da Silva on 20/08/26.
//

import SwiftUI

struct LineSearch: View {
    var search: String
    var body: some View {
        HStack{
            Text(search)

        }
    }
}

#Preview {
    LineSearch(search: "Exemplo")
}
