//
//  VaccineCardHistory.swift
//  Patta
//
//  Created by João Cláudio dos Santos Souza on 19/08/26.
//

import SwiftUI
import CoreData

struct VaccineCardHistory: View {
    
    let vaccineRegistry: VaccineRegistry
    
    var body: some View {
        HStack(spacing: 20) {
            Image(systemName: "syringe")
                .font(.title)
            
            VStack {
                Text(vaccineRegistry.vaccine?.title ?? "")
                    .font(.body.bold())
                
                Text(vaccineRegistry.applicationDate?.formatted(date: .numeric, time: .omitted) ?? "")
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}

#Preview {
    let context = DataController.shared.container.viewContext
    let vaccineRegistry = VaccineRegistry(context: context)
    let vaccine = Vaccine(context: context)
    
    vaccine.title = "Antirrábica"
    
    vaccineRegistry.vaccine = vaccine
    vaccineRegistry.applicationDate = Date()
    
    
    
    return VaccineCardHistory(vaccineRegistry: vaccineRegistry)
}
