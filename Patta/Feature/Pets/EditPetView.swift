//
//  EditPetView.swift
//  Patta
//
//  Created by João Cláudio dos Santos Souza on 19/08/26.
//

import SwiftUI
import CoreData
import PhotosUI

struct EditPetView: View {
    
    @Environment(VaccineRegistryViewModel.self) private var registryViewModel
    @Environment(VaccineRegistryListStore.self) private var vaccineRegistryListStore

    
    let pet: PetModel
    let viewModel: PetViewModel
    
    @State private var selectedImage: PhotosPickerItem?
    @State private var confirmDelete: Bool = false
    @Binding var navPath: [PetRoute]
    
    private let portugueseBrazilLocale = Locale(identifier: "pt_BR")
    private var portugueseBrazilCalendar: Calendar {
        var calendar = Calendar(identifier: .gregorian)
        calendar.locale = portugueseBrazilLocale
        return calendar
    }
    
    init(pet: PetModel, viewModel: PetViewModel, navPath: Binding<[PetRoute]>) {
        self.pet = pet
        self.viewModel = viewModel
        _navPath = navPath
    }
    
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
            }
            
            Color.clear
                .ignoresSafeArea()
            
            ScrollView {
                VStack {
                    PhotosPicker(selection: $selectedImage, matching: .images) {
                        VStack(spacing: 20) {
                            Text("Adicionar Imagem")
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
                        
                        TextField("Nome", text: $viewModelBind.name)
                            .padding(12)
                        
                        Divider()
                        
                        DatePicker(
                            "Data de Nascimento",
                            selection: Binding(
                                get: { viewModelBind.birthdate ?? Date.now },
                                set: { viewModelBind.birthdate = $0 }
                            ),
                            in: ...Date.now,
                            displayedComponents: .date
                        )
                        .padding(12)
                        
                        Divider()
                        
                        TextField("Peso", value: $viewModelBind.weight, format: .number)
                            .keyboardType(.decimalPad)
                            .padding(12)
                            .overlay(alignment: .trailing) {
                                Text("kg")
                                    .foregroundStyle(.secondary)
                            }
                        
                        Divider()
                        
                        TextField("Raça", text: $viewModelBind.breed)
                            .padding(12)
                        
                        Divider()
                        
                        TextField("Condições Médicas", text: $viewModelBind.medicalConditions)
                            .padding(12)
                    }
                    .padding()
                    .background(.regularMaterial, in: RoundedRectangle(cornerRadius: 20))
                    
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Cor do pet:")
                            .font(.headline)

                        PetColorPicker(
                            selection: $viewModelBind.selectedColorName
                        )
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
                                            Text(registry.vaccine.title)
                                                .foregroundStyle(.primary)

                                            Text(
                                                registry.applicationDate?
                                                    .formatted(
                                                        date: .abbreviated,
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
                            if viewModel.deletePet(id: pet.id) {
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
        .environment(\.locale, portugueseBrazilLocale)
        .environment(\.calendar, portugueseBrazilCalendar)
        .toolbar {
            ToolbarItem(placement: .cancellationAction) {
                Button("Cancelar", role: .cancel) {
                    viewModel.cancelEditing()
                    navPath.removeLast()
                }
            }
            
            ToolbarItem(placement: .confirmationAction) {
                Button {
                    if viewModel.savePet() {
                        navPath.removeLast()
                    }
                } label: {
                    Text("Salvar")
                        .foregroundStyle(.white)
                }
            }
        }
        .navigationBarBackButtonHidden(true)
        .onAppear {
            viewModel.prepareToEdit(pet)
        }
    }
}

#Preview {
    @Previewable @State var navPath: [PetRoute] = []
    let context = DataController.shared.container.viewContext
    let name = "Toto"
    let breed = "Beagle"
    let myPetBirthdate = Calendar.current.date(from: DateComponents(year: 2023, month: 5, day: 10))
    let birthdate = myPetBirthdate
    
    let pet = PetModel(id: UUID(), name: name, breed: breed, birthdate: birthdate, image: nil)
    
    let repository = CoreDataPetRepository(context: context)
    let store = PetListStore(repository: repository)
    let viewModel = PetViewModel(name: "", store: store)
    let vaccineRepository = CoreDataVaccineRepository(context: context)
    let vaccineStore = VaccineListStore(repository: vaccineRepository)
    let vaccineRegistryRepository = CoreDataVaccineRegistryRepository(context: context)
    let vaccineRegistryStore = VaccineRegistryListStore(repository: vaccineRegistryRepository)
    
    EditPetView(pet: pet, viewModel: viewModel, navPath: $navPath)
        .environment(VaccineRegistryViewModel(store: vaccineRegistryStore))
        .environment(vaccineRegistryStore)
        .environment(vaccineStore)
}
