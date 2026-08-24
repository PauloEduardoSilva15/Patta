//
//  VaccineCardHistory.swift
//  Patta
//
//  Created by João Cláudio dos Santos Souza on 19/08/26.
//

import SwiftUI
import CoreData

struct VaccineCardHistory: View {
    
    let vaccineRegistry: VaccineRegistryModel
    
    var body: some View {
        HStack(spacing: 20) {
            Image(systemName: "syringe")
                .font(.title)
            
            VStack(alignment: .leading) {
                Text("Vacina \(vaccineRegistry.vaccine.title)")
                    .font(.body.bold())
                
                Text(vaccineRegistry.applicationDate?.formatted(date: .numeric, time: .omitted) ?? "")
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}

#Preview {
    let vaccine = VaccineModel(id: UUID(), title: "Antirrábica")
    let vaccineRegistry = VaccineRegistryModel(id: UUID(), vaccine: vaccine)
    
    VaccineCardHistory(vaccineRegistry: vaccineRegistry)
}
