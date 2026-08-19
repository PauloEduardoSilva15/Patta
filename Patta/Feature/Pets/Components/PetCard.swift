//
//  PetCard.swift
//  Patta
//
//  Created by João Cláudio dos Santos Souza on 18/08/26.
//

import SwiftUI
import CoreData

struct PetCard: View {
    
    let pet: Pet
    let viewModel: PetViewModel
    
    var body: some View {
        NavigationLink {
            FocusedPetView(pet: pet, viewModel: viewModel)
        }label: {
            ZStack(alignment: .bottom) {
                if pet.image == nil {
                    Color.accentColor
                        .frame(height: 205)
                } else {
                    if let image = pet.image, let uiImage = UIImage(data: image) {
                        Image(uiImage: uiImage)
                            .resizable()
                            .scaledToFill()
                            .frame(maxWidth: .infinity)
                            .frame(height: 205)
                    }
                }
                
                HStack {
                    Image(systemName: "pawprint.fill")
                        .font(.system(size: 30))
                        .padding(.trailing, 5)
                    
                    VStack(alignment: .leading, spacing: 0) {
                        Text(pet.name ?? "")
                            .font(.title.bold())
                        
                        HStack {
                            if !(pet.breed ?? "").isEmpty && pet.birthdate != nil {
                                Text(pet.breed ?? "")
                                
                                Circle()
                                    .frame(width: 5, height: 5)
                                    .clipShape(Circle())
                                
                                Text("\(viewModel.getAge(birthdate: pet.birthdate ?? Date.now)) anos")
                            } else if !(pet.breed ?? "").isEmpty && pet.birthdate == nil {
                                Text(pet.breed ?? "")
                            } else {
                                Text("\(viewModel.getAge(birthdate: pet.birthdate ?? Date.now)) anos")
                            }
                        }
                        .font(.body)
                        
                    }
                    
                    Spacer()
                    
                    Image(systemName: "chevron.right.circle.fill")
                        .font(.system(size: 25))
                        .foregroundStyle(.button)
                        .symbolRenderingMode(.monochrome)
                }
                .padding(.horizontal)
                .padding(.vertical, 12)
                .background(.ultraThinMaterial)
            }
            .clipShape(RoundedRectangle(cornerRadius: 10))
        }
        .buttonStyle(.plain)
        .navigationLinkIndicatorVisibility(.hidden)
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
    
    return PetCard(pet: pet, viewModel: viewModel)
}
