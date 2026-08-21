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
    
    @Environment(\.managedObjectContext) private var context
    @Environment(VaccineRegistryViewModel.self) private var registryViewModel
    
    let pet: Pet
    let viewModel: PetViewModel
    @Environment(\.dismiss) private var dismiss
    
    @State private var selectedImage: PhotosPickerItem?
    @State private var vaccineRegistryTitle: [String] = []
    @State private var vaccineRegistryDate: [Date] = []
    @State private var confirmDelete: Bool = false
    @Binding var navPath: [PetRoute]
    
    @FetchRequest private var registries: FetchedResults<VaccineRegistry>
    @FetchRequest(sortDescriptors: [NSSortDescriptor(keyPath: \Vaccine.title, ascending: true)]) private var vaccines: FetchedResults<Vaccine>
    
    private let portugueseBrazilLocale = Locale(identifier: "pt_BR")
    private var portugueseBrazilCalendar: Calendar {
        var calendar = Calendar(identifier: .gregorian)
        calendar.locale = portugueseBrazilLocale
        return calendar
    }
    
    init(pet: Pet, viewModel: PetViewModel, navPath: Binding<[PetRoute]>) {
        self.pet = pet
        self.viewModel = viewModel
        _navPath = navPath
        _registries = FetchRequest(sortDescriptors: [NSSortDescriptor(keyPath: \VaccineRegistry.applicationDate, ascending: false)], predicate: NSPredicate(format: "pet == %@", pet))
    }
    
    var body: some View {
        
        @Bindable var viewModelBind = viewModel
        @Bindable var registryViewModelBind = registryViewModel
        
        ZStack(alignment: .bottom) {
            if let image = viewModel.petImage, let UIImage = UIImage(data: image) {
                GeometryReader { geo in
                    Image(uiImage: UIImage)
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
                        
                        DatePicker("Data de Nascimento",
                                   selection: Binding(
                                    get: { viewModelBind.birthdate ?? Date.now },
                                    set: { viewModelBind.birthdate = $0 }
                                   ),
                                   in: ...Date.now, displayedComponents: .date)
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
                    .background(
                        .regularMaterial,
                        in: RoundedRectangle(cornerRadius: 20)
                    )
                    
                    VStack(alignment: .leading, spacing: 0) {
                        Text("Vacinas:")
                            .font(.headline)
                            .padding(.bottom, 10)
                        
                        if !registries.isEmpty {
                            
                            ForEach(registries) { registry in
                                EditableVaccineRegistryRow(
                                    registry: registry,
                                    vaccines: Array(vaccines)
                                )
                            }
                        } else {
                            Text("Não há vacinas registradas. \n\nCadastre uma nova vacina na aba de \"Histórico de Vacinas\"")
                                .padding(.top, 20)
                                .padding(.leading, 20)
                        }
                    }
                    .padding()
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background(.regularMaterial, in: RoundedRectangle(cornerRadius: 20))
                    
                    Button {
                        confirmDelete = true
                    }label: {
                        Label("Excluir Pet", systemImage: "trash.fill")
                            .font(.body.weight(.medium))
                            .foregroundStyle(.red)
                            .frame(maxWidth: .infinity)
                            .contentShape(Rectangle())
                            .padding(.vertical, 10)
                            .glassEffect(.regular.interactive())
                    }
                    .confirmationDialog("Deseja realmente excluir o pet?", isPresented: $confirmDelete, titleVisibility: .visible) {
                        Button("Deletar", role: .destructive) {
                            if viewModel.deletePet(pet) {
                                
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
                    context.rollback()
                    viewModel.cancelEditing()
                    dismiss()
                }
            }
            
            ToolbarItem(placement: .confirmationAction) {
                Button(role: .confirm) {
                    if viewModel.savePet() {
                        dismiss()
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

private struct EditableVaccineRegistryRow: View {
    @ObservedObject var registry: VaccineRegistry
    
    let vaccines: [Vaccine]
    
    private var selectedVaccine: Binding<Vaccine?> {
        Binding(
            get: { registry.vaccine },
            set: { registry.vaccine = $0 }
        )
    }
    
    private var applicationDate: Binding<Date> {
        Binding(
            get: { registry.applicationDate ?? Date.now },
            set: { registry.applicationDate = $0 }
        )
    }
    
    var body: some View {
        Picker("Vacina", selection: selectedVaccine) {
            Text("Selecione uma vacina")
                .tag(Vaccine?.none)
            
            ForEach(vaccines) { vaccine in
                Text(vaccine.title ?? "")
                    .tag(Optional(vaccine))
            }
        }
        .padding(12)
        
        Divider()
        
        DatePicker("Data",
                   selection: applicationDate,
                   in: ...Date.now, displayedComponents: .date)
        .padding(12)
    }
}



#Preview {
    EditPetPreview()
}

private struct EditPetPreview: View {
    @State private var navPath: [PetRoute] = []
    
    private let context = DataController.shared.container.viewContext
    
    var body: some View {
        EditPetView(pet: makePet(), viewModel: PetViewModel(context: context), navPath: $navPath)
            .environment(\.managedObjectContext, context)
            .environment(VaccineRegistryViewModel(context: context))
    }
    
    private func makePet() -> Pet {
        let pet = Pet(context: context)
        pet.name = "Totó"
        pet.breed = "Beagle"
        pet.birthdate = Calendar.current.date(from: DateComponents(year: 2023, month: 5, day: 10))
        
        if let uiImage = UIImage(named: "ImageTest") {
            pet.image = uiImage.pngData()
        }
        
        return pet
    }
}

