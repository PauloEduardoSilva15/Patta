//
//  LineTask.swift
//  Patta
//
//  Created by Pedro Canute on 18/08/26.
//

import CoreData
import SwiftUI

struct LineTask: View {
    @State var playHaptic: Bool = false
    @ObservedObject var task: Task
    
    let onOpenDetails: () -> Void
    let onComplete: () -> Void
    
    private var petName: String {
        if task.appliesToAllPets {
            return "Todos"
        }
        
        return task.pet?.name ?? "Pet indisponível"
    }
    
    @ViewBuilder
    private var petImage: some View {
        if let imageData = task.pet?.image, let uiImage = UIImage(data: imageData) {
            Image(uiImage: uiImage)
                .resizable()
                .scaledToFill()
                .frame(width: 65, height: 65)
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
        if task.appliesToAllPets {
            PetNameBadge(
                name: "Todos",
                colorName: PetColorPalette.defaultAssetName
            )
        } else if let pet = task.pet {
            ObservedPetBadge(pet: pet)
        } else {
            PetNameBadge(
                name: "Pet indisponível",
                colorName: PetColorPalette.defaultAssetName
            )
        }
    }
    
    var body: some View {
        HStack(spacing: 0) {
            
            Button(action: onOpenDetails) {
                HStack(spacing: 12) {
                    petImage
                    
                    VStack(alignment: .leading, spacing: 8) {
                        Text(task.title ?? "Título da tarefa")
                            .font(.body)
                            .fontWeight(.medium)
                            .lineLimit(2)
                            .minimumScaleFactor(0.75)
                            .allowsTightening(true)
                            .fixedSize(horizontal: false, vertical: true)
                        
                        HStack (spacing: 4){
                            
                           petBadge
                                .background {
                                    Capsule()
                                        .fill(Color(task.pet?.color ?? "petAzul"))
                                }
                            if task.usesCustomDate {
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
                    }
                    
                    Spacer()
                }
                .frame(
                    maxWidth: .infinity,
                    maxHeight: .infinity,
                    alignment: .leading
                )
                .padding(.trailing, 12)
                .contentShape(Rectangle())
            }
            .buttonStyle(.plain)
            .simultaneousGesture(
                TapGesture().onEnded {
                    playHaptic.toggle()
                }
            )
            .sensoryFeedback(.selection, trigger: playHaptic)
            
            Button(action: onComplete) {
                Image(systemName: task.isComplete ? "checkmark.circle.fill" : "circle")
                    .font(.system(size: 25))
                    .foregroundStyle(.accent)
                    .frame(width: 44, height: 44)
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
}

private struct ObservedPetBadge: View {
    @ObservedObject var pet: Pet

    var body: some View {
        PetNameBadge(
            name: pet.name ?? "Pet sem nome",
            colorName: pet.color
        )
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
            .frame(minWidth: 70, maxWidth: 80)
            .frame(height: 20)
            .background {
                Capsule()
                    .fill(
                        PetColorPalette.color(
                            for: colorName
                        )
                    )
            }
    }
}

#Preview {
    let task: Task = {
        let context = DataController.shared.container.viewContext
        let task = Task(context: context)
        
        task.title = """
        Dar comida e depois ir no mercado comprar tapetinho
        """
        
        task.appliesToAllPets = true
        
        return task
    }()
    
    LineTask(task: task, onOpenDetails: {}, onComplete: {})
        .padding(8)
        .background {
            Color(.background)
        }
}
