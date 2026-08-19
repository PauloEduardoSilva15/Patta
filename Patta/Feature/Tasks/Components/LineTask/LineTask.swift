//
//  LineTask.swift
//  Patta
//
//  Created by Pedro Canute on 18/08/26.
//

import CoreData
import SwiftUI

struct LineTask<Destination: View>: View {
    
    @ObservedObject var task: Task
    
    let onComplete: () -> Void
    let destination: () -> Destination
    
    private var petName: String {
        if task.appliesToAllPets {
            return "Todos"
        }
        
        return task.pet?.name ?? "Pet indisponível"
    }
    
    var body: some View {
        HStack(spacing: 0) {
            
            NavigationLink {
                destination()
            } label: {
                HStack(spacing: 12) {
                    Circle()
                        .fill(.photoGray)
                        .frame(width: 65, height: 65)
                        .overlay {
                            Image(systemName: "pawprint.fill")
                                .foregroundStyle(.accent)
                                .font(.title)
                        }
                    
                    VStack(alignment: .leading, spacing: 8) {
                        Text(task.title ?? "Título da tarefa")
                            .font(.body)
                            .fontWeight(.medium)
                            .lineLimit(2)
                            .minimumScaleFactor(0.75)
                            .allowsTightening(true)
                            .fixedSize(horizontal: false, vertical: true)
                        
                        Capsule()
                            .fill(.blue)
                            .frame(width: 70, height: 25)
                            .overlay {
                                Text(petName)
                                    .font(.footnote)
                                    .fontWeight(.medium)
                                    .foregroundStyle(.white)
                            }
                    }
                    
                    Spacer()
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .leading)
                .padding(.trailing, 12)
            }
            .navigationLinkIndicatorVisibility(.hidden)
            .buttonStyle(.plain)
            
            Button(action: onComplete) {
                Image(
                    systemName: task.isComplete
                    ? "checkmark.circle.fill"
                    : "circle"
                )
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
                .fill(
                    Color(
                        uiColor: .secondarySystemGroupedBackground
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
    
    NavigationStack {
        LineTask(
            task: task,
            onComplete: {}
        ) {
            TaskDetails()
        }
        .padding(8)
        .background {
            Color(.background)
        }
    }
}
