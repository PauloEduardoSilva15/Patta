//
//  TaskView.swift
//  Patta
//
//  Created by Paulo Eduardo Barbosa da Silva on 17/08/26.
//

import SwiftUI
import CoreData

struct TaskView:View {
    @State private var viewModel: TaskViewModel
    @State private var showSheetTask: Bool = false
    @State private var showSheetFilter: Bool = false
    @State var selectedDate = Date()
    init(context: NSManagedObjectContext) {
        _viewModel = State(initialValue: TaskViewModel(context: context))
    }
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
                    
                    LineTask(task: task){
                        
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
                    .environment(viewModel)
            }
            
                
        }
        .sheet(isPresented: $showSheetFilter) {
            TaskFilter()
        }
        
    }
    

}


