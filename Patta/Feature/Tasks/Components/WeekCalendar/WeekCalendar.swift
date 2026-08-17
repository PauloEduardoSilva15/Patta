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
    
    private func goNextWeek() {
        if currentWeekOffset < weekOffsetRange.last! {
            currentWeekOffset += 1
        }
    }
    
    private func goPreviousWeek() {
        if currentWeekOffset != 0 {
            currentWeekOffset -= 1
        }
    }
    
    var body: some View {
        VStack(spacing: 10) {
            HStack {
                Text(selectedDate.formatted(.dateTime.month(.abbreviated).locale(Locale(identifier: "pt_BR"))).capitalized + " " + selectedDate.formatted(.dateTime.year()))
                    .font(.title3.bold())
                
                Spacer()
                
                HStack(spacing: 40) {
                    Button {
                        goPreviousWeek()
                    }label: {
                        Image(systemName: "chevron.left")
                            .font(.title3.weight(.medium))
                            .foregroundStyle(.primary)
                    }
                    .buttonStyle(.plain)
                    .containerShape(Rectangle())
                    
                    Button {
                        goNextWeek()
                    }label: {
                        Image(systemName: "chevron.right")
                            .font(.title3.weight(.medium))
                            .foregroundStyle(.primary)
                    }
                    .buttonStyle(.plain)
                    .containerShape(Rectangle())
                }
            }
            
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
