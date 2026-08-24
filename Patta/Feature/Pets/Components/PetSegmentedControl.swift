//
//  PetSegmentedControl.swift
//  Patta
//
//  Created by João Cláudio dos Santos Souza on 19/08/26.
//

import SwiftUI

enum PetTab: String, CaseIterable {
    case info = "Informações do Pet"
    case vaccines = "Histórico de Vacinas"
}

struct PetSegmentedControl: View {
    
    @Binding var selectedTab: PetTab
    @Namespace private var animation
    
    var body: some View {
        HStack(spacing: 5) {
            ForEach(PetTab.allCases, id: \.self) { tab in
                Text(tab.rawValue)
                    .font(.subheadline.bold())
                    .foregroundStyle(selectedTab == tab ? .white : .primary)
                    .padding(.vertical, 5)
                    .frame(maxWidth: .infinity)
                    .background {
                        if selectedTab == tab {
                            Capsule()
                                .fill(.accent)
                                .matchedGeometryEffect(id: "background", in: animation)
                        }
                    }
                    .contentShape(Capsule())
                    .onTapGesture {
                        withAnimation(.snappy(duration: 0.3)) {
                            selectedTab = tab
                        }
                    }
            }
        }
        .frame(maxWidth: .infinity)
        .padding(4)
        .background(Color(.systemGray6), in: Capsule())
    }
}

#Preview {
    @Previewable @State var selectedTab: PetTab = .info
    
    PetSegmentedControl(selectedTab: $selectedTab)
}
