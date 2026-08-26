//
//  TaskSheet.swift
//  Patta
//
//  Created by Pedro Canute on 18/08/26.
//
import SwiftUI
import SwiftData

struct TaskSheet: View {
    @Environment(\.dismiss) private var dismiss

    @Environment(TaskViewModel.self) private var taskViewModel

    @Environment(PetListStore.self) private var petListStore

    @State private var isShowingDeleteConfirmation = false

    var body: some View {
        @Bindable var taskViewModelBind = taskViewModel

        NavigationStack {
            Form {
                TextField("Título",text: $taskViewModelBind.title)

                TextField("Descrição", text: $taskViewModelBind.taskDescription)

                petSection(taskViewModelBind: $taskViewModelBind)

                dateSection(taskViewModelBind: $taskViewModelBind)

                prioritySection(taskViewModelBind: $taskViewModelBind)

                recurrenceSection(taskViewModelBind: $taskViewModelBind)

                deleteSection
            }
            .navigationTitle(taskViewModel.formTitle)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                cancellationButton
                confirmationButton
            }
            .confirmationDialog("Deletar tarefa?", isPresented: $isShowingDeleteConfirmation, titleVisibility: .visible) {
                Button("Deletar Tarefa", role: .destructive) {
                    deleteCurrentTask()
                }

                Button("Cancelar",role: .cancel) {}
            } message: {
                Text(
                    """
                    Esta ação não pode \
                    ser desfeita.
                    """
                )
            }
            .alert("Não foi possível concluir a operação", isPresented: Binding(
                    get: {
                        taskViewModel
                            .errorMessage != nil
                    },
                    set: { isPresented in
                        if !isPresented {
                            taskViewModel
                                .errorMessage = nil
                        }
                    }
                )
            ) {
                Button("OK", role: .cancel) {}
            } message: {
                Text(taskViewModel.errorMessage ?? "")
            }
        }
        .onAppear {
            petListStore.refresh()
        }
    }

    private func petSection(taskViewModelBind: Bindable<TaskViewModel>) -> some View {
        Section {
            Picker("Pets", selection: taskViewModelBind.selectedPet) {
                Text("Todos")
                    .tag(nil as PetModel?)

                ForEach(petListStore.pets) { pet in
                    Text(pet.name)
                        .tag(Optional(pet))
                }
            }
        } header: {
            Text("Aplicar tarefa a")
        }
    }

    private func dateSection(taskViewModelBind: Bindable<TaskViewModel>) -> some View {
        Section {
            Toggle("Agendar Tarefa",isOn: taskViewModelBind.usesCustomDate)
            .tint(.accent)

            if taskViewModel
                .usesCustomDate {

                DatePicker("Data",selection: taskViewModelBind.date)
                .environment(\.locale, Locale(identifier: "pt_BR"))
            }
        }
    }

    private func prioritySection(taskViewModelBind: Bindable<TaskViewModel>) -> some View {
        Section {
            Toggle("Tarefa Prioritária",isOn: taskViewModelBind.isPriority)
            .tint(.accent)
        } footer: {
            Text(
                """
                Use esta opção para destacar \
                tarefas importantes.
                """
            )
        }
    }

    private func recurrenceSection(taskViewModelBind: Bindable<TaskViewModel>) -> some View {
        Section {
            Toggle("Repetir diariamente",isOn: taskViewModelBind.isRecurring)
            .tint(.accent)

            if taskViewModel.isRecurring {
                Toggle("Limitar recorrência",isOn:taskViewModelBind.hasRecurrenceLimit)
                .tint(.accent)

                if taskViewModel.hasRecurrenceLimit {

                    Stepper(
                        """
                        Duração: \
                        \(taskViewModel.recurrenceDays) dias
                        """,
                        value: taskViewModelBind.recurrenceDays,
                        in: 1...12,
                        step: 1)
                }
            }
        } header: {
            Text("Recorrência")
        } footer: {
            recurrenceFooter
        }
    }

    @ViewBuilder
    private var recurrenceFooter: some View {
        if taskViewModel.isRecurring {
            Text(
                """
                Quando esta tarefa for concluída, \
                ela será reagendada automaticamente \
                para o próximo dia.
                """
            )
        } else {
            Text(
                """
                Ative esta opção para repetir \
                a tarefa todos os dias.
                """
            )
        }
    }

    @ViewBuilder
    private var deleteSection: some View {
        if taskViewModel.taskBeingEdited != nil {
            Section {
                Button(
                    "Deletar Tarefa",
                    role: .destructive
                ) {
                    isShowingDeleteConfirmation =
                        true
                }
            }
        }
    }

    @ToolbarContentBuilder
    private var cancellationButton:
        some ToolbarContent {

        ToolbarItem(
            placement: .cancellationAction
        ) {
            Button {
                taskViewModel.cancelEditing()
                dismiss()
            } label: {
                Image(systemName: "xmark")
            }
        }
    }

    @ToolbarContentBuilder
    private var confirmationButton:
        some ToolbarContent {

        ToolbarItem(placement: .confirmationAction) {
            Button {
                if taskViewModel.saveTask() {
                    dismiss()
                }
            } label: {
                Image(systemName: "checkmark")
                    .foregroundStyle(.white)
            }
            .buttonStyle(.borderedProminent)
            .tint(.accent)
        }
    }

    private func deleteCurrentTask() {
        guard let task =
            taskViewModel.taskBeingEdited
        else {
            return
        }

        if taskViewModel.deleteTask(task) {
            dismiss()
        }
    }
}


