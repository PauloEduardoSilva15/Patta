//
//  CardTask.swift
//  Patta
//
//  Created by Paulo Eduardo Barbosa da Silva on 18/08/26.
//

import SwiftUI

struct CardTask: View {
    var taskTitle: String
    var taskIcon: String
    @State var isMarked: Bool
    @State var isPriority: Bool
    var body: some View {
        HStack(spacing: 100){
            HStack(spacing: 10){
                Image(systemName: taskIcon)
                    .foregroundStyle(.red)
                Text(taskTitle)
                Image(systemName: "star.fill")
                    .foregroundStyle(isPriority ? .pink : .clear)
                
            }
            Button{
                isMarked.toggle()
            } label: {
                Image(systemName: isMarked ? "checkmark.circle.fill" : "circle")
            }
        }.font(.title2)
    }
}


#Preview {
    CardTask(taskTitle: "Nome da tarefa", taskIcon: "heart.fill", isMarked: false, isPriority: true)
}
