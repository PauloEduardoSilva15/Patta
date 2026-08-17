//
//  DayGroup.swift
//  Patta
//
//  Created by João Cláudio dos Santos Souza on 15/08/26.
//

import SwiftUI

struct DayGroup: View {
    let date: Date
    let isSelected: Bool
    let isToday: Bool

    var body: some View {
        VStack(spacing: 0) {
            
            Text(date.formatted(.dateTime.weekday(.abbreviated).locale(Locale(identifier: "pt-BR"))))
                .font(.caption2)
                .foregroundStyle(isSelected ? .primary : .secondary)
            
            Spacer()
            
            if isSelected {
                Text(date.formatted(.dateTime.day()))
                    .font(.headline)
                    .foregroundStyle(.primary)
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
            } else {
                Text(date.formatted(.dateTime.day()))
                    .font(.headline)
                    .fontWeight(isToday ? .bold : .regular)
                    .foregroundStyle(.secondary)
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
            }
        }
        .padding(.vertical, 10)
        .background(RoundedRectangle(cornerRadius: 5).foregroundStyle(.quinary).brightness(isSelected ? 0.5 : 0))
        .overlay {
            if isSelected {
                RoundedRectangle(cornerRadius: 5).stroke(.primary, lineWidth: 1)
            }
            
            if isToday && !isSelected {
                RoundedRectangle(cornerRadius: 5).stroke(.tint, lineWidth: 1)
            }
        }
    }
}

#Preview {
    
    let date = Date()
    let isSelected = false
    let isToday = false
    
    
    DayGroup(date: date, isSelected: isSelected, isToday: isToday)
}
