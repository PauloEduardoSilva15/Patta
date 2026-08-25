//
//  LineTask.swift
//  Patta
//
//  Created by Pedro Canute on 18/08/26.
//

import SwiftUI

struct LineTask: View {
    @State private var playHaptic = false

    let task: TaskModel

    let onOpenDetails: () -> Void
    let onComplete: () -> Void

    @ViewBuilder
    private var petImage: some View {
        if let imageData = task.pet?.image,
           let uiImage = UIImage(
                data: imageData
           ) {
            Image(uiImage: uiImage)
                .resizable()
                .scaledToFill()
                .frame(width: 65, height: 65 )
                .clipShape(Circle())
        } else {
            Circle()
                .fill(.photoGray)
                .frame(width: 65, height: 65)
                .overlay {
                    Image(systemName: "pawprint.fill")
                    .foregroundStyle(.accent)
                    .font(.title)
                }
        }
    }

    @ViewBuilder
    private var petBadge: some View {
        if let pet = task.pet {
            PetNameBadge(name: pet.name,colorName: pet.color)
        } else {
            PetNameBadge(name: "Todos", colorName: PetColorPalette.defaultAssetName)
        }
    }

    var body: some View {
        HStack(spacing: 0) {
            Button(action: onOpenDetails) {
                HStack(spacing: 12) {
                    petImage

                    VStack(alignment: .leading, spacing: 8) {
                        Text(task.title)
                            .font(.body)
                            .fontWeight(.medium)
                            .lineLimit(2)
                            .minimumScaleFactor(0.75)
                            .allowsTightening(true)
                            .fixedSize(horizontal: false, vertical: true)

                        HStack(spacing: 4) {
                            petBadge

                            if task.usesCustomDate == true {
                                customDateBadge
                            }
                        }
                    }

                    Spacer()
                }
                .frame(maxWidth: .infinity,maxHeight: .infinity, alignment: .leading)
                .padding(.trailing, 12)
                .contentShape(Rectangle())
            }
            .buttonStyle(.plain)
            .simultaneousGesture(
                TapGesture().onEnded {
                    playHaptic.toggle()
                }
            )
            .sensoryFeedback(.selection,trigger: playHaptic)

            Button(action: onComplete) {
                Image(systemName: task.isCompleted ? "checkmark.circle.fill" : "circle")
                .font(.system(size: 25))
                .foregroundStyle(.accent)
                .frame(width: 44,height: 44)
                .contentShape(Rectangle())
            }
            .buttonStyle(.plain)
        }
        .frame(maxWidth: .infinity)
        .frame(height: 100)
        .padding(.horizontal, 8)
        .background {
            RoundedRectangle(cornerRadius: 20)
            .fill(Color(uiColor: .secondarySystemGroupedBackground))
        }
    }

    private var customDateBadge: some View {
        Capsule()
            .fill(.orange)
            .frame(width: 70, height: 20)
            .overlay {
                Text(task.date?.formatted(date: .omitted, time: .shortened) ?? "--:--")
                .font(.caption2)
                .fontWeight(.semibold)
                .foregroundStyle(.white)
            }
    }
}

private struct PetNameBadge: View {
    let name: String
    let colorName: String?

    var body: some View {
        Text(name)
            .font(.caption2)
            .fontWeight(.semibold)
            .foregroundStyle(.white)
            .lineLimit(1)
            .minimumScaleFactor(0.8)
            .truncationMode(.tail)
            .padding(.horizontal, 12)
            .frame(minWidth: 70,maxWidth: 80)
            .frame(height: 20)
            .background {
                Capsule()
                    .fill(PetColorPalette.color(for: colorName))
            }
    }
}

//#Preview {
//    let task = TaskModel(
//        id: UUID(),
//        title:
//            """
//            Dar comida e comprar \
//            tapetinho no mercado
//            """,
//        description: "",
//        createdAt: Date(),
//        date: Date(),
//        completedAt: nil,
//        usesCustomDate: true,
//        isPriority: true,
//        isRecurring: false,
//        recurrenceEndDate: nil,
//        isCompleted: false,
//        pet: nil
//    )
//
//    LineTask(task: task,onOpenDetails: {},onComplete: {})
//    .padding(8)
//    .background {
//        Color(.background)
//    }
//}
