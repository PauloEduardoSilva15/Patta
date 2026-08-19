//
//  FocusedPetView.swift
//  Patta
//
//  Created by João Cláudio dos Santos Souza on 19/08/26.
//

import SwiftUI
import CoreData

struct FocusedPetView: View {

    let pet: Pet
    let viewModel: PetViewModel
    
    @State private var selectedTab: PetTab = .info
    
    var body: some View {
        ZStack {
            if let image = pet.image, let UIImage = UIImage(data: image) {
                GeometryReader { geo in
                    Image(uiImage: UIImage)
                        .resizable()
                        .scaledToFill()
                        .frame(maxWidth: geo.size.width)
                        .clipped()
                        .ignoresSafeArea()
                }
            }
            
            VStack {
                
                Spacer()
                    VStack(alignment: .leading, spacing: 0) {
                        
                        PetSegmentedControl(selectedTab: $selectedTab)
                            .padding(.bottom, 10)
                        
                        if selectedTab == .info {
                            PetInformationView(pet: pet, viewModel: viewModel)
                        } else {
                            
                        }
                    }
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 20))
            }
            .padding()
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
        .toolbar {
            ToolbarItemGroup(placement: .topBarTrailing) {
                Button {
                    
                }label: {
                    Text("Editar")
                }
            }
        }
        .toolbar(.hidden, for: .tabBar)
    }
}

struct PetInformationView: View {
    
    let pet: Pet
    let viewModel: PetViewModel
    
    var body: some View {
        Text((pet.name ?? "").isEmpty ? "Nome" : pet.name ?? "")
            .foregroundStyle((pet.name ?? "").isEmpty ? .secondary : .primary)
            .padding(12)
        
        Divider()
        
        Text(pet.birthdate == nil ? "Idade" : viewModel.getAge(birthdate: pet.birthdate ?? Date.now) + " anos")
            .foregroundStyle(pet.birthdate == nil ? .secondary : .primary)
            .padding(12)
        
        Divider()
        
        Text((pet.breed ?? "").isEmpty ? "Raça" : pet.breed ?? "")
            .foregroundStyle((pet.breed ?? "").isEmpty ? .secondary : .primary)
            .padding(12)
        
        Divider()
        
        Text((pet.med_cond ?? "").isEmpty ? "Condições Médicas" : pet.med_cond ?? "")
            .foregroundStyle((pet.med_cond ?? "").isEmpty ? .secondary : .primary)
            .padding(12)
    }
}

#Preview {
    let context = DataController.shared.container.viewContext
    let pet = Pet(context: context)
    
    pet.name = "Toto"
    pet.breed = "Beagle"
    let myPetBirthdate = Calendar.current.date(from: DateComponents(year: 2023, month: 5, day: 10))
    pet.birthdate = myPetBirthdate
    
    if let uiImage = UIImage(named: "ImageTest") {
        pet.image = uiImage.pngData()
    }
    
    let viewModel = PetViewModel(name: "", context: context)
    
    return FocusedPetView(pet: pet, viewModel: viewModel)
}
