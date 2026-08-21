//
//  PetColorPicker.swift
//  Patta
//
//  Created by Pedro Canute on 20/08/26.
//

import SwiftUI

struct PetColorOption: Identifiable, Hashable {
    let assetName: String
    let title: String

    var id: String {
        assetName
    }
}

enum PetColorPalette {
    static let defaultAssetName = "petAzul"

    static let options = [
        PetColorOption(assetName: "petAbobora", title: "Abóbora"),
        PetColorOption(assetName: "petAmarelo", title: "Amarelo"),
        PetColorOption(assetName: "petAzul", title: "Azul"),
        PetColorOption(assetName: "petBebe", title: "Bebê"),
        PetColorOption(assetName: "petCereja", title: "Cereja"),
        PetColorOption(assetName: "petCinza", title: "Cinza"),
        PetColorOption(assetName: "petLilas", title: "Lilás"),
        PetColorOption(assetName: "petMarrom", title: "Marrom"),
        PetColorOption(assetName: "petRoxo", title: "Roxo"),
        PetColorOption(assetName: "petSalmao", title: "Salmão"),
        PetColorOption(assetName: "petVerde", title: "Verde"),
        PetColorOption(assetName: "petVermelho", title: "Vermelho")
    ]

    static func normalizedAssetName(_ assetName: String?) -> String {
        option(for: assetName).assetName
    }

    static func title(for assetName: String?) -> String {
        option(for: assetName).title
    }

    static func color(for assetName: String?) -> Color {
        Color(normalizedAssetName(assetName))
    }

    private static func option(
        for assetName: String?
    ) -> PetColorOption {
        options.first {
            $0.assetName == assetName
        } ?? PetColorOption(
            assetName: defaultAssetName,
            title: "Azul"
        )
    }
}

struct PetColorPicker: View {
    @Binding var selection: String

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
            ForEach(PetColorPalette.options) { option in
                Button {
                    selection = option.assetName
                } label: {
                    ZStack {
                        Circle()
                            .fill(
                                PetColorPalette.color(
                                    for: option.assetName
                                )
                            )
                            .frame(width: 36, height: 36)

                        if selection == option.assetName {
                            Circle()
                                .stroke(.primary, lineWidth: 3)
                                .frame(width: 42, height: 42)

                            Image(systemName: "checkmark")
                                .font(.caption.bold())
                                .foregroundStyle(.white)
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
