//
//  TaskView.swift
//  Patta
//
//  Created by Paulo Eduardo Barbosa da Silva on 17/08/26.
//

import SwiftUI
import CoreData

struct TaskView:View {
    @Environment(\.managedObjectContext) private var viewContext
    @State private var showSheetTask: Bool = false
    @State var selectedDate = Date()
    
    @FetchRequest(
        entity: Task.entity(),
        sortDescriptors: [NSSortDescriptor(keyPath: \Task.title, ascending: true)],
        
    ) var tasks: FetchedResults<Task>
    
    var allTasks: [String] {
        var items: [String] = []
        for task in tasks {
            if let name = task.title {
                items.append(name)
            }
        }
        return items
    }
    
    var body: some View {
        NavigationStack{
            VStack {
                WeekCalendar(selectedDate: $selectedDate)
                    .padding()
                
                Text(Calendar.current.isDateInToday(selectedDate) ? "Hoje:" : selectedDate.formatted(date: .numeric, time: .omitted)+":")
                    .bold()
                
                List(allTasks, id: \.self) { task in
                    //CardTask(taskTitle: task, taskIcon: <#T##String#>, isMarked: <#T##Bool#>, isPriority: <#T##Bool#>)
                }
            }
            
        }
        .navigationTitle("Tarefa")
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button {
                    showSheetTask.toggle()
                } label: {
                    Image(systemName: "plus")
                }
            }
        }
    }
}
#Preview {
    NavigationStack {
        TaskView()
    }
}
