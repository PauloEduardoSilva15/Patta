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
    
    var body: some View {
        
        @Bindable var viewModelBind = viewModel
        
        VStack {
            HStack {
                Button {
                    dismiss()
                }label: {
                    Image(systemName: "xmark")
                        .font(.title3.weight(.medium))
                }
                .buttonStyle(.plain)
                .frame(width: 44, height: 44)
                .glassEffect(.regular.interactive())
                
                Spacer()
                
                Text("Novo Pet")
                    .font(.body.weight(.semibold))
                
                Spacer()
                
                Button {
                    do {
                        try viewModel.addNewPet()
                        dismiss()
                    } catch {
                        
                    }
                }label: {
                    Image(systemName: "checkmark")
                        .font(.title3.weight(.medium))
                }
                .buttonStyle(.plain)
                .frame(width: 44, height: 44)
                .glassEffect(.regular.tint(.accentColor).interactive())
            }
            .padding()
            .padding(.bottom, 20)
            
            PhotosPicker(selection: $selectedImage, matching: .images) {
                VStack(spacing: 20) {
                    if let image = viewModel.petImage, let uiImage = UIImage(data: image) {
                        Image(uiImage: uiImage)
                            .resizable()
                            .scaledToFill()
                            .frame(width: 200, height: 200)
                            .clipShape(Circle())
                    } else {
                        ZStack {
                            
                            Circle()
                                .fill(.accent)
                                .frame(width: 200, height: 200)
                            
                            Image(systemName: "photo")
                                .font(.system(size: 80))
                        }
                    }
                    
                    Text("Adicionar Imagem")
                        .fontWeight(.medium)
                    
                    if viewModel.errorMessage != "" {
                        Text(viewModel.errorMessage)
                            .foregroundStyle(.red)
                            .bold()
                    }
                }
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
                        .onChange(of: willSetBirthdate) { _, newValue in
                            if newValue {
                                viewModelBind.birthdate = Date.now
                            } else {
                                viewModelBind.birthdate = nil
                            }
                        }
                    
                    if willSetBirthdate {
                        DatePicker("Data de Nascimento",
                                   selection: Binding(
                                    get: { viewModelBind.birthdate ?? Date.now },
                                    set: { viewModelBind.birthdate = $0 }
                                   ),
                                   in: ...Date.now, displayedComponents: .date)
                        .transition(.opacity)
                    }
                }
            }
            .scrollDismissesKeyboard(.interactively)
            .animation(.snappy, value: willSetBirthdate)
        }
    }
}

#Preview {
    
    let context = DataController.shared.container.viewContext
    let viewModel = PetViewModel(name: "", context: context)
    
    SheetAddPet()
        .environment(viewModel)
        .environment(\.managedObjectContext, context)
}
