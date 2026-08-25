//
//  PetCard.swift
//  Patta
//
//  Created by João Cláudio dos Santos Souza on 18/08/26.
//

import SwiftUI
import SwiftData

struct PetCard: View {
    
    let pet: PetModel
    let viewModel: PetViewModel
    
    var body: some View {
        Group {
            if let imageData = pet.image,
               let uiImage = UIImage(data: imageData) {
                
                GeometryReader { geo in
                    Image(uiImage: uiImage)
                        .resizable()
                        .scaledToFill()
                        .frame(maxWidth: geo.size.width)
                        .clipped()
                }
                
            } else {
                PetColorPalette.color(for: pet.color)
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
                    Text(pet.name.isEmpty ? "Pet sem nome" : pet.name)
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
                            Text(viewModel.getAge(birthdate: birthdate))
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
    let config = ModelConfiguration(isStoredInMemoryOnly: true)
    let container = try! ModelContainer(for: PetModel.self, configurations: config)
    let context = container.mainContext
    
    let name = "Toto"
    let breed = "Beagle"
    let myPetBirthdate = Calendar.current.date(from: DateComponents(year: 2023, month: 5, day: 10))
    let birthdate = myPetBirthdate
    
    let image = UIImage(
        named: "ImageTest"
    )?.pngData()
    
    let pet = PetModel(
        id: UUID(),
        name: name,
        breed: breed,
        birthdate: birthdate,
        image: image
    )
    
    let repository = SwiftDataPetRepository(context: context)
    let store = PetListStore(repository: repository)
    let viewModel = PetViewModel(name: "", store: store)
    
    PetCard(pet: pet, viewModel: viewModel)
        .modelContainer(container)
}
