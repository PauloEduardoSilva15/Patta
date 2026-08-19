//
//  LineTask.swift
//  Patta
//
//  Created by Pedro Canute on 18/08/26.
//

import CoreData
import SwiftUI

struct LineTask: View {
    
    @ObservedObject var task: Task
    @State private var isShowingTaskSheet = false
    
    let onComplete: () -> Void
    
    private var petName: String {
        if task.appliesToAllPets {
            return "Todos"
        }
        
        return task.pet?.name ?? "Pet indisponível"
    }
    
    var body: some View {
        HStack(spacing: 12) {
            Circle()
                .fill(.photoGray)
                .frame(width: 65, height: 65)
                .overlay {
                    Image(systemName: "pawprint.fill")
                        .foregroundStyle(.accent)
                        .font(.title)
                }
            
            VStack (alignment: .leading ,spacing: 8){
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
            
            Button(action: onComplete){
                
                Image(systemName: task.isComplete ? "checkmark.circle.fill" : "circle")
                    .font(.system(size: 25))
                    .foregroundStyle(.accent)
                    .frame(width: 44, height: 44)
                
            }
            .buttonStyle(.plain)
        }
        .frame(maxWidth:.infinity)
        .frame(height: 100)
        .padding(.horizontal, 8)
        .background {
            RoundedRectangle(cornerRadius: 20)
                .fill(Color(uiColor: .secondarySystemGroupedBackground))
        }
    }
}
#Preview {
    let task: Task = {
        let context = DataController.shared.container.viewContext
        let task = Task(context: context)
        task.title = "Dar comida e depois ir no mercado comprar tapetinho"
        task.appliesToAllPets = true
        return task
    }()
    
    LineTask(task: task) {}
        .padding(8)
        .background {
            Color(.background)
            
        }
}
