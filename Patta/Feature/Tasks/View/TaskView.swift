//
//  TaskView.swift
//  Patta
//
//  Created by Paulo Eduardo Barbosa da Silva on 17/08/26.
//

import SwiftUI
import CoreData

struct TaskView:View {
    @Environment(TaskViewModel.self) private var viewModel
    @State private var showTaskSheet: Bool = false
    @State private var showSheetFilter: Bool = false
    @State var selectedDate = Date()
    @State var selectedPet: Pet?
    @State var selectedTab = 0
    
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
    
    private var tasksFilteredByDateAndPet: [Task] {
        let calendar = Calendar.current
        
        return tasks.filter { task in
            guard let taskDate = task.date else {
                return false
            }
            
            guard calendar.isDate(
                taskDate,
                inSameDayAs: selectedDate
            ) else {
                return false
            }
            
            guard let selectedPet else {
                return true
            }
            
            return task.appliesToAllPets || task.pet?.objectID == selectedPet.objectID
        }
    }
    
    private var pendingTasks: [Task] {
        tasksFilteredByDateAndPet
            .filter { !$0.isComplete }
            .sorted {
                ($0.date ?? .distantFuture) < ($1.date ?? .distantFuture)
            }
    }
    
    private var completedTasks: [Task] {
        tasksFilteredByDateAndPet
            .filter { $0.isComplete }
            .sorted {
                ($0.completedAt ?? .distantPast) > ($1.completedAt ?? .distantPast)
            }
    }
    
    private var isPetFilterActive: Bool {
        selectedPet != nil
    }

    private var petFilterButton: some View {
        Menu {
            Picker("Pets", selection: $selectedPet) {
                Text("Todos")
                    .tag(nil as Pet?)

                ForEach(allPets, id: \.objectID) { pet in
                    Text(pet.name ?? "Sem Nome")
                        .tag(Optional(pet))
                }
            }
            .pickerStyle(.inline)
        } label: {
            Label("Filtrar", systemImage: isPetFilterActive ? "pawprint.fill": "pawprint")
                .labelStyle(.titleAndIcon)
            .foregroundStyle(isPetFilterActive ? Color.blue : Color.primary)
            .padding(6)
        }
        .menuStyle(.button)
        .buttonStyle(.plain)
    }
    
    private var petFilterMenu: some View {
        petFilterButton
    }
    
    var body: some View {
        VStack {
            WeekCalendar(selectedDate: $selectedDate)
                .padding(.horizontal,12)
            
            
            Picker("Tarefas agendadas", selection: $selectedTab) {
                Text("Pendentes")
                    .tag(0)
                Text("Concluídas")
                    .tag(1)
            }
            .pickerStyle(.segmented)
            .padding(12)
            
            switch selectedTab {
            case 0:
                PendingTasks(tasks: pendingTasks)
                
            case 1:
                CompletedTasks(tasks: completedTasks)
                
            default:
                PendingTasks(tasks: pendingTasks)
            }
        }
        .background {
            Color(.background)
                .ignoresSafeArea()
        }
        .navigationTitle("Tarefa")
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                petFilterMenu
            }
              
            ToolbarItem(placement: .navigationBarTrailing) {
                Button {
                    viewModel.prepareNewTask()
                    showTaskSheet = true
                } label: {
                    Image(systemName: "plus")
                        .foregroundStyle(.white)
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
#Preview {
    
    let dataController = DataController.shared
    let context = dataController.container.viewContext
    let taskViewModel = TaskViewModel(context: context)
    
    TaskView()
        .environment(taskViewModel)
        .environment(\.managedObjectContext, context)
}
