//
//  PetCard.swift
//  Patta
//
//  Created by João Cláudio dos Santos Souza on 18/08/26.
//

import SwiftUI
import CoreData

struct PetCard: View {
    
    let pet: PetModel
    let viewModel: PetViewModel
    
    var body: some View {
        NavigationLink(value: PetRoute.detail(pet)) {
            ZStack(alignment: .bottom) {
                if pet.image == nil {
                    Color.accentColor
                    
                } else {
                    if let image = pet.image, let uiImage = UIImage(data: image) {
                        GeometryReader { geo in
                            Image(uiImage: uiImage)
                                .resizable()
                                .scaledToFill()
                                .frame(maxWidth: geo.size.width)
                                .clipped()
                                .ignoresSafeArea()
                        }
                    }
                }
                
                HStack() {
                    Image(systemName: "pawprint.fill")
                        .font(.system(size: 30))
                    
                    VStack(alignment: .leading, spacing: 0) {
                        Text(pet.name)
                            .font(.title2.bold())
                        
                        HStack {
                            if !(pet.breed ?? "").isEmpty && pet.birthdate != nil {
                                Text(pet.breed ?? "")
                                    .font(.caption)
                                
                                Circle()
                                    .frame(width: 5, height: 5)
                                    .clipShape(Circle())
                                
                                Text("\(viewModel.getAge(birthdate: pet.birthdate ?? Date.now)) anos")
                                    .font(.caption)
                            } else if !(pet.breed ?? "").isEmpty && pet.birthdate == nil {
                                Text(pet.breed ?? "")
                                    .font(.caption)
                            } else {
                                Text("\(viewModel.getAge(birthdate: pet.birthdate ?? Date.now)) anos")
                                    .font(.caption)
                            }
                        }
                        .font(.body)
                        
                    }
                }
                .padding(.horizontal, 5)
                .padding(.vertical, 5)
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(.regularMaterial)
            }
            .clipShape(RoundedRectangle(cornerRadius: 10))
        }
        .buttonStyle(.plain)
        .navigationLinkIndicatorVisibility(.hidden)
    }
}

#Preview {
    let context = DataController.shared.container.viewContext
    
    let name = "Toto"
    let breed = "Beagle"
    let myPetBirthdate = Calendar.current.date(from: DateComponents(year: 2023, month: 5, day: 10))
    let birthdate = myPetBirthdate
    
    if let uiImage = UIImage(named: "ImageTest") {
        let image = uiImage.pngData()
    }
    
    let pet = PetModel(id: UUID(), name: name, breed: breed, birthdate: birthdate, image: nil)
    
    let repository = CoreDataPetRepository(context: context)
    let store = PetListStore(repository: repository)
    let viewModel = PetViewModel(name: "", store: store)
    
    PetCard(pet: pet, viewModel: viewModel)
}
