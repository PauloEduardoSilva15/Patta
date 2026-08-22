//
//  SheetAddPet.swift
//  Patta
//
//  Created by João Cláudio dos Santos Souza on 17/08/26.
//

import SwiftUI
import CoreData
import PhotosUI

struct SheetAddPet: View {
    
    @Environment(\.dismiss) var dismiss
    @Environment(PetViewModel.self) private var viewModel
    
    @State private var willSetBirthdate = false
    @State private var selectedImage: PhotosPickerItem?
    
    private let portugueseBrazilLocale = Locale(identifier: "pt_BR")
    private var portugueseBrazilCalendar: Calendar {
        var calendar = Calendar(identifier: .gregorian)
        calendar.locale = portugueseBrazilLocale
        return calendar
    }
    
    var body: some View {
        
        @Bindable var viewModelBind = viewModel
        let petImage = viewModel.petImage
        
        NavigationStack {
            VStack {
                PhotosPicker(selection: $selectedImage, matching: .images) {
                    VStack(spacing: 20) {
                        if let image = petImage, let uiImage = UIImage(data: image) {
                            Image(uiImage: uiImage)
                                .resizable()
                                .scaledToFill()
                                .frame(width: 150, height: 150)
                                .clipShape(Circle())
                        } else {
                            ZStack {
                                
                                Circle()
                                    .fill(.accent)
                                    .frame(width: 150, height: 150)
                                
                                Image(systemName: "photo")
                                    .font(.system(size: 50))
                                    .foregroundStyle(.white)
                            }
                        }
                        
                        Text("Adicionar Imagem")
                            .fontWeight(.medium)

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
                
                Form {
                    TextField("Nome", text: $viewModelBind.name)
                    TextField("Peso", value: $viewModelBind.weight, format: .number)
                        .keyboardType(.decimalPad)
                        .overlay(alignment: .trailing) {
                            Text("kg")
                                .foregroundStyle(.secondary)
                        }
                    TextField("Raça", text: $viewModelBind.breed)
                    TextField("Condições Médicas", text: $viewModelBind.medicalConditions)
                    
                    Section {
                        Toggle("Inserir Data de Nascimento", isOn: $willSetBirthdate)
                            .tint(.accent)
                            .onChange(of: willSetBirthdate) { _, newValue in
                                if newValue {
                                    viewModelBind.birthdate = Date.now
                                } else {
                                    viewModelBind.birthdate = nil
                                }
                            }
                        
                        if willSetBirthdate {
                            DatePicker("",
                                       selection: Binding(
                                        get: { viewModelBind.birthdate ?? Date.now },
                                        set: { viewModelBind.birthdate = $0 }
                                       ),
                                       in: ...Date.now, displayedComponents: .date)
                            .transition(.opacity)
                        }
                    }
                    
                    Section("Cor do pet") {
                        PetColorPicker(
                            selection: $viewModelBind.selectedColorName
                        )
                    }
                }
                .scrollDismissesKeyboard(.interactively)
                .animation(.snappy, value: willSetBirthdate)
            }
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button(role: .cancel) {
                        viewModel.cancelEditing()
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .principal) {
                    Text("Novo Pet")
                        .font(.body.weight(.semibold))
                }
                
                ToolbarItem(placement: .confirmationAction) {
                    Button(role: .confirm) {
                        if viewModel.savePet() {
                            dismiss()
                        }
                    }
                }
            }
        }
        .alert(
            "Não foi possível salvar",
            isPresented: Binding(
                get: { viewModel.errorMessage != nil },
                set: { isPresented in
                    if !isPresented {
                        viewModel.errorMessage = nil
                    }
                }
            )
        ) {
            Button("OK", role: .cancel) {}
        } message: {
            Text(viewModel.errorMessage ?? "")
        }
    }
}

#Preview {
    
    let context = DataController.shared.container.viewContext
    let repository = CoreDataPetRepository(context: context)
    let store = PetListStore(repository: repository)
    let viewModel = PetViewModel(name: "", store: store)
    
    SheetAddPet()
        .environment(viewModel)
        .environment(\.managedObjectContext, context)
}
