//
//  WeekRow.swift
//  Patta
//
//  Created by João Cláudio dos Santos Souza on 15/08/26.
//

import SwiftUI

struct WeekRow: View {
    let days: [Date]
    @Binding var selectedDate: Date

    private let calendar = Calendar.current

    var body: some View {
        HStack(spacing: 5) {
            ForEach(days, id: \.self) { day in
                DayGroup(
                    date: day,
                    isSelected: calendar.isDate(day, inSameDayAs: selectedDate),
                    isToday: calendar.isDateInToday(day)
                )
                .frame(maxWidth: .infinity, maxHeight: 34)
                .contentShape(Rectangle())
                .onTapGesture {
                    withAnimation(.snappy(duration: 0.25)) {
                        selectedDate = day
                    }
                }
            }
        }
    }
}

#Preview {
    @Previewable @State var selectedDate = Date()
    let days = [Date(), Date(), Date(), Date(), Date(), Date()]
    
    WeekRow(days: days, selectedDate: $selectedDate)
}
