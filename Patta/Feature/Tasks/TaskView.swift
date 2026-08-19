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
    @State private var showSheetFilter: Bool = false
    @State var selectedDate = Date()
    let context = NSManagedObjectContext(concurrencyType: .mainQueueConcurrencyType)
    @FetchRequest(
        entity: Task.entity(),
        sortDescriptors: [NSSortDescriptor(keyPath: \Task.date, ascending: true)],
        
    ) var tasks: FetchedResults<Task>
    
    var allTasks: [Task] {
        var items: [Task] = []
        for task in tasks {
            items.append(task)
        }
        return items
    }
    
    var body: some View {
        NavigationStack{
            VStack {
                WeekCalendar(selectedDate: $selectedDate)
                    .padding()
                
                Text(Calendar.current.isDateInToday(selectedDate) ? "Hoje:" : selectedDate.formatted(date: .numeric, time: .omitted)+":")
                    .multilineTextAlignment(.leading)
                    .bold()
                
                
                
                List(allTasks, id: \.self) { task in
                    
                    if task.date == selectedDate{
                        CardTask(taskTitle: task.title ?? "Tarefa Sem Nome", taskIcon: "heart", isMarked: false, isPriority: task.isPriority)
                            .swipeActions(edge: .leading) {
                                Button {
                                    
                                } label: {
                                    Label("Editar", systemImage: "pencil")
                                }
                            }
                    }
                }
            }
            
        }
        .navigationTitle("Tarefa")
        .toolbar {
            
            ToolbarItem(placement: .navigationBarTrailing) {
                Button {
                    showSheetFilter.toggle()
                } label: {
                    Image(systemName: "line.horizontal.3.decrease")
                }.buttonStyle(.glassProminent)
                
                
            }
            ToolbarItem(placement: .navigationBarTrailing) {
                Button {
                    showSheetTask.toggle()
                } label: {
                    Image(systemName: "plus")
                }.buttonStyle(.glassProminent)
            }
        }
        
        .sheet(isPresented: $showSheetTask) {
            NavigationStack{
                TaskSheet()
                    .environment(TaskViewModel(context: context))
                    .environment(\.managedObjectContext, context)
            }
            
                
        }
        .sheet(isPresented: $showSheetFilter) {
            TaskFilter()
        }
        
    }
    

}
#Preview {
    NavigationStack {
        TaskView()
    }
}
