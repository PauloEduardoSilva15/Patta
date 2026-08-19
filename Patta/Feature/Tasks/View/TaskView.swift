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
    @State private var showTaskSheet: Bool = false
    @State private var showSheetFilter: Bool = false
    @State var selectedDate = Date()
    @State var selectedPet: Pet?
    init(context: NSManagedObjectContext) {
        _viewModel = State(initialValue: TaskViewModel(context: context))
    }
    @FetchRequest(
        entity: Task.entity(),
        sortDescriptors: [NSSortDescriptor(keyPath: \Task.id, ascending: true)],
        
    ) var tasks: FetchedResults<Task>
    
    @FetchRequest(
        entity: Pet.entity(),
        sortDescriptors: [NSSortDescriptor(keyPath: \Pet.name, ascending: true)],
        
    ) var pets: FetchedResults<Pet>
    
    var allPets: [Pet]{
        var items: [Pet] = []
        for pet in pets {
            items.append(pet)
        }
        return items
    }
    
    
    
    
    var allTasks: [Task] {
        var items: [Task] = []
        for task in tasks {
            items.append(task)
        }
        return items
    }
    
    var allTasksinDay: [Task]{
        var items: [Task] = []
        let calendar = Calendar.current
        for task in allTasks{
            let taskDate = task.date ?? Date()
            if calendar.isDate(taskDate, inSameDayAs: selectedDate){
                items.append(task)
            }
            
        }
        return items
    }
    
    var allTaskInPet: [Task]{
        var items: [Task] = []
        
        if selectedPet == nil {
            for task in allTasksinDay{
                items.append(task)
            }
            return items
        }
        for task in allTasksinDay{
            if task.pet == selectedPet{
                items.append(task)
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
                    .multilineTextAlignment(.leading)
                    .bold()
                
                
                
                List(allTasksinDay, id: \.self) { task in
                    LineTask(task: task, onOpenDetails: {
                        viewModel.prepareToEdit(task)
                        showTaskSheet = true
                    }, onComplete: {
                        viewModel.completeTask(task)
                    }) .listRowSeparator(.hidden)
                        .listRowBackground(Color.clear)
                    .listRowInsets(EdgeInsets(top: 6, leading: 12, bottom: 6, trailing: 12))
                        .swipeActions(edge: .trailing, allowsFullSwipe: true) {
                            Button (role: .destructive){
                                viewModel.deleteTask(task)
                            } label: {
                                Label("Deletar", systemImage: "trash")
                            }
                        }
                }
            }
            
        }
        .navigationTitle("Tarefa")
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Menu{
                    Button{
                        selectedPet = nil
                    }label: {
                        HStack{
                            Text("Todos")
                            if(selectedPet == nil){
                                Image(systemName: "checkmark")
                            }
                        }
                    }
                    ForEach(allPets, id: \.self){ pet in
                        Button{
                            selectedPet = pet
                        }label: {
                            HStack{
                                Text((pet.name ?? "Sem Nome"))
                                if selectedPet != nil && selectedPet == pet {
                                    Image(systemName: "checkmark")
                                }
                            }
                            
                            
                        }
                        
                    }
                }label: {
                    Image(systemName: "line.horizontal.3.decrease")
                }.buttonStyle(.glass)
                
            }
            ToolbarItem(placement: .navigationBarTrailing) {
                Button {
                    showTaskSheet.toggle()
                } label: {
                    Image(systemName: "plus")
                }.buttonStyle(.glassProminent)
                
            }
        }
        
        .sheet(isPresented: $showTaskSheet) {
            NavigationStack{
                TaskSheet()
                    .environment(viewModel)
            }
            
                
        }
        
        
    }
    

}
