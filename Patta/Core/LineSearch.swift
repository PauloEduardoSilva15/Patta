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
        HStack(spacing: 200){
            Text(search)
            Image(systemName: "chevron.right")
        }
    }
}

#Preview {
    LineSearch(search: "Exemplo")
}
