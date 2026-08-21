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
        Group {
            if let imageData = pet.image,
               let uiImage = UIImage(data: imageData) {
                
                Image(uiImage: uiImage)
                    .resizable()
                    .scaledToFill()
                
            } else {
                Color.accentColor
            }
        }
        .frame(maxWidth: .infinity)
        .frame(height: 210)
        .clipped()
        .overlay(alignment: .bottom) {
            HStack(spacing: 8) {
                Image(systemName: "pawprint.fill")
                    .font(.system(size: 18))
                    .frame(width: 24)
                
                VStack(alignment: .leading, spacing: 3) {
                    Text(pet.name ?? "Pet sem nome")
                        .font(.headline)
                        .fontWeight(.bold)
                        .lineLimit(2)
                        .minimumScaleFactor(0.8)
                        .frame( maxWidth: .infinity, alignment: .leading)
                    
                    HStack(spacing: 5) {
                        if let breed = pet.breed,
                           !breed.isEmpty {
                            Text(breed)
                                .lineLimit(1)
                        }
                        
                        if let breed = pet.breed,
                           !breed.isEmpty,
                           pet.birthdate != nil {
                            
                            Circle()
                                .frame(width: 4, height: 4)
                        }
                        
                        if let birthdate = pet.birthdate {
                            Text(
                                "\(viewModel.getAge(birthdate: birthdate)) anos"
                            )
                            .lineLimit(1)
                        }
                    }
                    .font(.caption)
                    .foregroundStyle(.secondary)
                }
                .layoutPriority(1)
            }
            .padding(.horizontal, 10)
            .frame(maxWidth: .infinity)
            .frame(height: 52)
            .background(.regularMaterial)
        }
        .clipShape(
            RoundedRectangle(cornerRadius: 10)
        )
    }
}
#Preview {
    PetCardPreview()
}

private struct PetCardPreview: View {
    private let context = DataController.shared.container.viewContext
    
    var body: some View {
        PetCard(pet: makePet(), viewModel: PetViewModel(context: context))
    }
    
    private func makePet() -> Pet {
        let pet = Pet(context: context)
        pet.name = "Toto"
        pet.breed = "Beagle"
        pet.birthdate = Calendar.current.date(from: DateComponents(year: 2023, month: 5, day: 10))
        
        if let uiImage = UIImage(named: "ImageTest") {
            pet.image = uiImage.pngData()
        }
        
        return pet
    }
}
