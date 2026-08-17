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
    @State var selectedDate = Date()
    
    @FetchRequest(
        entity: Tarefa.entity(),
        sortDescriptors: [NSSortDescriptor(keyPath: \Tarefa.titulo, ascending: true)],
        
    ) var tasks: FetchedResults<Tarefa>
    var body: some View {
        NavigationStack{
            VStack{
                
                WeekCalendar(selectedDate: $selectedDate)
                
                Text(Calendar.current.isDateInToday(selectedDate) ? "Hoje" : selectedDate.formatted(date: .numeric, time: .omitted))
                    .bold()
            
            }
        }
        .navigationTitle("Tarefa")
    }
}
#Preview {
    Task()
}
