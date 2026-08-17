//
//  Task.swift
//  Patta
//
//  Created by Paulo Eduardo Barbosa da Silva on 17/08/26.
//

import SwiftUI
import CoreData

struct Task:View {
    @Environment(\.managedObjectContext) private var viewContext
    @State private var showSheetTask: Bool = false
    @State var selectedDate = Date()
    
    @FetchRequest(
        entity: Tarefa.entity(),
        sortDescriptors: [NSSortDescriptor(keyPath: \Tarefa.titulo, ascending: true)],
        
    ) var tasks: FetchedResults<Tarefa>
    
    var allTasks: [String] {
        var items: [String] = []
        for task in tasks {
            if let name = task.titulo {
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
                
                Text(Calendar.current.isDateInToday(selectedDate) ? "Hoje" : selectedDate.formatted(date: .numeric, time: .omitted))
                    .bold()
                
                List(allTasks, id: \.self) { task in
                    Text(task)
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
        Task()
    }
}
