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
    
    @Environment(\.dismiss) private var dismiss
    @Environment(VaccineRegistryViewModel.self) private var registryViewModel
    
    let pet: Pet
    let viewModel: PetViewModel
    
    @State private var selectedImage: PhotosPickerItem?
    @State private var vaccineRegistryTitle: [String] = []
    @State private var vaccineRegistryDate: [Date] = []
    
    @FetchRequest private var registries: FetchedResults<VaccineRegistry>
    @FetchRequest(sortDescriptors: [NSSortDescriptor(keyPath: \Vaccine.title, ascending: true)]) private var vaccines: FetchedResults<Vaccine>
    
    init(pet: Pet, viewModel: PetViewModel) {
        self.pet = pet
        self.viewModel = viewModel
        _registries = FetchRequest(sortDescriptors: [NSSortDescriptor(keyPath: \VaccineRegistry.applicationDate, ascending: false)], predicate: NSPredicate(format: "pet == %@", pet))
    }
    
    var body: some View {
        
        @Bindable var viewModelBind = viewModel
        @Bindable var registryViewModelBind = registryViewModel
        
        NavigationStack {
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
                                
                                if viewModel.errorMessage != "" {
                                    Text(viewModel.errorMessage)
                                        .foregroundStyle(.red)
                                        .bold()
                                }
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
                        
                        VStack(alignment: .leading, spacing: 0) {
                            Text("Vacinas:")
                                .font(.headline)
                                .padding(.bottom, 10)
                            
                            ForEach(registries) { registry in
                                Picker("Vacina", selection: $registryViewModelBind.selectedVaccine) {
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
                                           selection: Binding(
                                            get: { viewModelBind.birthdate ?? Date.now },
                                            set: { viewModelBind.birthdate = $0 }
                                           ),
                                           in: ...Date.now, displayedComponents: .date)
                                .padding(12)
                            }
                        }
                        .padding()
                        .background(.regularMaterial, in: RoundedRectangle(cornerRadius: 20))
                    }
                    .padding()
                }
                .padding(0)
                .frame(maxHeight: 420)
                .scrollIndicators(.hidden)
            }
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button(role: .cancel) {
                        viewModel.clearForm()
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .confirmationAction) {
                    Button(role: .confirm) {
                        
                    }
                }
            }
            .navigationBarBackButtonHidden(true)
        }
        .onAppear() {
            if let petImage = pet.image {
                viewModel.petImage = petImage
                viewModel.name = pet.name ?? ""
                viewModel.breed = pet.breed ?? ""
                viewModel.medicalConditions = pet.med_cond ?? ""
                viewModel.birthdate = pet.birthdate ?? Date.now
            }
        }
    }
}

#Preview {
    let context = DataController.shared.container.viewContext
    let pet = Pet(context: context)
    
    pet.name = "Totó"
    pet.breed = "Beagle"
    let myPetBirthdate = Calendar.current.date(from: DateComponents(year: 2023, month: 5, day: 10))
    pet.birthdate = myPetBirthdate
    
    if let uiImage = UIImage(named: "ImageTest") {
        pet.image = uiImage.pngData()
    }
    
    let viewModel = PetViewModel(name: "", context: context)
    
    return EditPetView(pet: pet, viewModel: viewModel)
        .environment(VaccineRegistryViewModel(context: context))
}
