//
//  WeekCalendar.swift
//  Patta
//
//  Created by João Cláudio dos Santos Souza on 15/08/26.
//

import SwiftUI

struct WeekCalendar: View {
    @Binding var selectedDate: Date
    
    @State private var currentWeekOffset = 0
    
    private let calendar = Calendar.current
    
    private let weekOffsetRange = 0...52
    
    var body: some View {
        VStack(spacing: 10) {
            Text(selectedDate.formatted(.dateTime.month(.wide).year()))
                .font(.title3.bold())
            
            TabView(selection: $currentWeekOffset) {
                ForEach(weekOffsetRange, id: \.self) { offset in
                    WeekRow(
                        days: daysOfTheWeek(offset: offset),
                        selectedDate: $selectedDate
                    )
                    .padding(.horizontal, 4)
                }
            }
            .tabViewStyle(.page(indexDisplayMode: .never))
            .frame(height: 80)
        }
    }
    
    private func daysOfTheWeek(offset: Int) -> [Date] {
        let today = Date()
        guard
            let currentWeekStart = calendar.dateInterval(of: .weekOfYear, for: today)?.start,
            let weekStart = calendar.date(byAdding: .weekOfYear, value: offset, to: currentWeekStart)
        else { return [] }
        
        return (0..<7).compactMap {
            calendar.date(byAdding: .day, value: $0, to: weekStart)
        }
    }
}

#Preview {
    
    @Previewable @State var selectedDate = Date()
    
    WeekCalendar(selectedDate: $selectedDate)
}
