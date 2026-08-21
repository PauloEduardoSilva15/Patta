//
//  PetColorPicker.swift
//  Patta
//
//  Created by Pedro Canute on 20/08/26.
//

import SwiftUI

struct PetColorPicker: View {
    @Binding var selection: String

    private struct PetColorOption: Identifiable {
        let assetName: String
        let title: String

        var id: String {
            assetName
        }
    }

    private let colors = [
        PetColorOption(
            assetName: "petAbobora",
            title: "Abóbora"
        ),
        PetColorOption(
            assetName: "petAmarelo",
            title: "Amarelo"
        ),
        PetColorOption(
            assetName: "petAzul",
            title: "Azul"
        ),
        PetColorOption(
            assetName: "petBebe",
            title: "Bebê"
        ),
        PetColorOption(
            assetName: "petCereja",
            title: "Cereja"
        ),
        PetColorOption(
            assetName: "petCinza",
            title: "Cinza"
        ),
        PetColorOption(
            assetName: "petLilas",
            title: "Lilás"
        ),
        PetColorOption(
            assetName: "petMarrom",
            title: "Marrom"
        ),
        PetColorOption(
            assetName: "petRoxo",
            title: "Roxo"
        ),
        PetColorOption(
            assetName: "petSalmao",
            title: "Salmão"
        ),
        PetColorOption(
            assetName: "petVerde",
            title: "Verde"
        ),
        PetColorOption(
            assetName: "petVermelho",
            title: "Vermelho"
        )
    ]

    private let columns = [
        GridItem(
            .adaptive(minimum: 44, maximum: 44),
            spacing: 8
        )
    ]

    var body: some View {
        LazyVGrid(
            columns: columns,
            alignment: .leading,
            spacing: 8
        ) {
            ForEach(colors) { option in
                Button {
                    selection = option.assetName
                } label: {
                    ZStack {
                        Circle()
                            .fill(Color(option.assetName))
                            .frame(width: 36, height: 36)

                        if selection == option.assetName {
                            Circle()
                                .stroke(.primary, lineWidth: 3)
                                .frame(width: 42, height: 42)

                            Image(systemName: "checkmark")
                                .font(.caption.bold())
                                .foregroundStyle(.white)
                                .shadow(
                                    color: .black.opacity(0.5),
                                    radius: 1
                                )
                        }
                    }
                    .frame(width: 44, height: 44)
                    .contentShape(Circle())
                }
                .buttonStyle(.plain)
                .accessibilityLabel(option.title)
                .accessibilityValue(
                    selection == option.assetName
                    ? "Selecionada"
                    : "Não selecionada"
                )
            }
        }
        .padding(.vertical, 6)
    }
}
