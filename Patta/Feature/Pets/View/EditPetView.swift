//
//  EditPetView.swift
//  Patta
//
//  Created by João Cláudio dos Santos Souza on 19/08/26.
//

import SwiftUI
import SwiftData
import PhotosUI

struct EditPetView: View {
    
    @Environment(VaccineRegistryViewModel.self) private var registryViewModel
    @Environment(VaccineRegistryListStore.self) private var vaccineRegistryListStore
    @Environment(TaskViewModel.self) private var taskViewModel

    
    let pet: PetModel
    let viewModel: PetViewModel
    @Environment(\.dismiss) private var dismiss
    
    @State private var selectedImage: PhotosPickerItem?
    @State private var confirmDelete: Bool = false
    @State private var actualPetColorSelected: String
    @Binding var navPath: [PetRoute]
    
    init(pet: PetModel, viewModel: PetViewModel, navPath: Binding<[PetRoute]>, isDismiss: Bool) {
        self.pet = pet
        self.viewModel = viewModel
        _navPath = navPath
        self.isDimmiss = isDismiss
        
        _actualPetColorSelected = State(
                initialValue: PetColorPalette.normalizedAssetName(pet.color))
    }
    
    @State var isDimmiss: Bool
    
    var body: some View {
        
        @Bindable var viewModelBind = viewModel
        
        ZStack(alignment: .bottom) {
            if let image = viewModel.petImage, let uiImage = UIImage(data: image) {
                GeometryReader { geo in
                    Image(uiImage: uiImage)
                        .resizable()
                        .scaledToFill()
                        .frame(maxWidth: geo.size.width)
                        .clipped()
                        .ignoresSafeArea()
                }
            } else {
                PetColorPalette.color(for: actualPetColorSelected)
                    .ignoresSafeArea()
            }
            
            Color.clear
                .ignoresSafeArea()
            
            ScrollView {
                VStack {
                    PhotosPicker(selection: $selectedImage, matching: .images) {
                        VStack(spacing: 20) {
                            Text("Alterar Imagem")
                                .fontWeight(.medium)
                                .padding()
                                .glassEffect(.regular.interactive())
                            
                        }
                        .padding(.bottom, 20)
                    }
                    .buttonStyle(.plain)
                    .onChange(of: selectedImage) { _, newImage in
                        Swift.Task {
                            let data = await viewModel.loadImage(from: newImage)
                            viewModel.petImage = data
                        }
                    }
                    
                    VStack(alignment: .leading, spacing: 0) {
                        Text("Informações Gerais:")
                            .font(.headline)
                            .padding(.bottom, 10)
                        
                        VStack(alignment: .leading, spacing: 10) {
                            
                            Text("Nome")
                                .font(.headline.bold())
                            
                            TextField("", text: $viewModelBind.name)
                                .font(.subheadline)
                        }
                        .padding(.vertical, 12)
                        
                        Divider()
                        
                        DatePicker(
                            "Data de Nascimento",
                            selection: Binding(
                                get: { viewModelBind.birthdate ?? Date.now },
                                set: { viewModelBind.birthdate = $0 }
                            ),
                            in: ...Date.now,
                            displayedComponents: .date,
                        )
                        .padding(.vertical, 12)
                        .datePickerStyle(.compact)
                        
                        Divider()
                        
                        VStack(alignment: .leading, spacing: 10) {
                            Text("Peso")
                                .font(.headline.bold())
                            
                            TextField("Não Informado", value: $viewModelBind.weight, format: .number)
                                .font(.subheadline)
                                .keyboardType(.decimalPad)
                                .overlay(alignment: .trailing) {
                                    Text("kg")
                                        .foregroundStyle(.secondary)
                                }
                        }
                        .padding(.vertical, 12)
                        
                        Divider()
                        
                        VStack(alignment: .leading, spacing: 10) {
                            Text("Raça")
                                .font(.headline.bold())
                            
                            TextField("Não Informado", text: $viewModelBind.breed)
                                .font(.subheadline)
                        }
                        .padding(.vertical, 12)
                        
                        Divider()
                        
                        VStack(alignment: .leading, spacing: 10) {
                            
                            Text("Condições Médicas")
                                .font(.headline.bold())
                            
                            TextField("Não Informado", text: $viewModelBind.medicalConditions)
                                .font(.subheadline)
                        }
                        .padding(.vertical, 12)
                    }
                    .padding()
                    .background(.regularMaterial, in: RoundedRectangle(cornerRadius: 20))
                    
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Cor do pet:")
                            .font(.headline)

                        PetColorPicker(
                            selection: $viewModelBind.selectedColorName
                        )
                        .onChange(of: viewModel.selectedColorName) {
                            actualPetColorSelected = viewModel.selectedColorName
                        }
                    }
                    .padding()
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background(.regularMaterial, in: RoundedRectangle(cornerRadius: 20))
                    
                    VStack(alignment: .leading, spacing: 0) {
                        Text("Vacinas:")
                            .font(.headline)
                            .padding(.bottom, 10)

                        if vaccineRegistryListStore.vaccineRegistries.isEmpty {
                            Text(
                                """
                                Não há vacinas registradas.

                                Cadastre uma nova vacina na aba \
                                "Histórico de Vacinas".
                                """
                            )
                            .foregroundStyle(.secondary)
                            .padding(.vertical, 20)
                        } else {
                            ForEach(
                                vaccineRegistryListStore.vaccineRegistries
                            ) { registry in
                                Button {
                                    registryViewModel.prepareForEditing(
                                        registry: registry
                                    )

                                    registryViewModel.activePetForSheet = pet
                                } label: {
                                    HStack {
                                        VStack(alignment: .leading, spacing: 5) {
                                            Text(registry.vaccine?.title ?? "Sem nome")
                                                .foregroundStyle(.primary)

                                            Text(
                                                registry.applicationDate?
                                                    .formatted(
                                                        date: .numeric,
                                                        time: .omitted
                                                    )
                                                ?? "Data não informada"
                                            )
                                            .font(.subheadline)
                                            .foregroundStyle(.secondary)
                                        }

                                        Spacer()

                                        Image(systemName: "chevron.right")
                                            .foregroundStyle(.secondary)
                                    }
                                    .padding(12)
                                    .contentShape(Rectangle())
                                }
                                .buttonStyle(.plain)

                                if registry.id !=
                                    vaccineRegistryListStore
                                        .vaccineRegistries
                                        .last?
                                        .id {

                                    Divider()
                                }
                            }
                        }
                    }
                    .padding()
                    .frame(
                        maxWidth: .infinity,
                        alignment: .leading
                    )
                    .background(
                        .regularMaterial,
                        in: RoundedRectangle(cornerRadius: 20)
                    )
                   
                    
                    Button {
                        confirmDelete = true
                    } label: {
                        Label("Excluir Pet", systemImage: "trash.fill")
                            .font(.body.weight(.medium))
                            .foregroundStyle(.red)
                            .frame(maxWidth: .infinity)
                            .contentShape(Rectangle())
                            .padding(.vertical, 10)
                            .glassEffect(.regular.interactive())
                    }
                    .confirmationDialog(
                        "Deseja realmente excluir o pet?",
                        isPresented: $confirmDelete,
                        titleVisibility: .visible
                    ) {
                        Button("Deletar", role: .destructive) {
                            let deletedTaskIDs = (pet.tasks ?? []).map(\.id)
                            
                            if viewModel.deletePet(id: pet.id) {
                                taskViewModel.handlePetCascadeDeletion(taskIDs: deletedTaskIDs)
                                
                                vaccineRegistryListStore.refresh(for: pet.id)
                                
                                if isDimmiss {
                                    dismiss()
                                    return
                                }
                                
                                navPath.removeAll()
                            }
                        }
                        
                        Button("Cancelar", role: .cancel) {
                            confirmDelete = false
                        }
                    } message: {
                        Text("Essa ação não pode ser desfeita!")
                    }
                }
                .padding()
            }
            .padding(0)
            .frame(maxHeight: 420)
            .scrollIndicators(.hidden)
        }
        .toolbar {
            ToolbarItem(placement: .cancellationAction) {
                Button("Cancelar", role: .cancel) {
                    dismiss()
                    
                }
            }
            
            ToolbarItem(placement: .confirmationAction) {
                Button {
                    if viewModel.savePet() {
                        dismiss()
                    }
                } label: {
                    Text("Salvar")
                        .foregroundStyle(.white)
                }
                .buttonStyle(.glassProminent)
            }
        }
        .navigationBarBackButtonHidden(true)
        .onAppear {
            viewModel.prepareToEdit(pet)
            actualPetColorSelected = PetColorPalette.normalizedAssetName(pet.color)
        }
    }
}

#Preview {
    @Previewable @State var navPath: [PetRoute] = []
    let config = ModelConfiguration(isStoredInMemoryOnly: true)
    let container = try! ModelContainer(
        for: PetModel.self,
        TaskModel.self,
        VaccineModel.self,
        VaccineRegistryModel.self,
        configurations: config
    )
    let context = container.mainContext
    let taskRepository =
        SwiftDataTaskRepository(context: context)

    let taskStore =
        TaskListStore(repository: taskRepository)

    let notificationService =
        LocalNotificationService()

    let taskViewModel = TaskViewModel(
        store: taskStore,
        notificationService: notificationService
    )
    let name = "Toto"
    let breed = "Beagle"
    let myPetBirthdate = Calendar.current.date(from: DateComponents(year: 2023, month: 5, day: 10))
    let birthdate = myPetBirthdate
    
    let pet = PetModel(id: UUID(), name: name, breed: breed, birthdate: birthdate, image: nil)
    
    let repository = SwiftDataPetRepository(context: context)
    let store = PetListStore(repository: repository)
    let viewModel = PetViewModel(name: "", store: store)
    let vaccineRepository = SwiftDataVaccineRepository(context: context)
    let vaccineStore = VaccineListStore(repository: vaccineRepository)
    let vaccineRegistryRepository = SwiftDataVaccineRegistryRepository(context: context)
    let vaccineRegistryStore = VaccineRegistryListStore(repository: vaccineRegistryRepository)
    
    EditPetView(pet: pet, viewModel: viewModel, navPath: $navPath, isDismiss: false)
        .environment(VaccineRegistryViewModel(store: vaccineRegistryStore))
        .environment(vaccineRegistryStore)
        .environment(vaccineStore)
        .modelContainer(container)
        .environment(taskViewModel)
}
