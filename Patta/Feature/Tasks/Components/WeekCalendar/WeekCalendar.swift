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
    @State private var isShowingDatePicker = false
    @State private var pendingDate = Date()

    private let calendar = Calendar.current
    private let weekOffsetRange = -52...52

    var body: some View {
        VStack(spacing: 10) {
            HStack {
                Button {
                    pendingDate = selectedDate
                    isShowingDatePicker = true
                } label: {
                    HStack(spacing: 5) {
                        Text(monthAndYearTitle)
                            .font(.headline)

                        Image(systemName: "chevron.down")
                            .font(.caption.weight(.semibold))
                    }
                    .foregroundStyle(.primary)
                }
                .buttonStyle(.plain)
                .accessibilityLabel("Selecionar outra data")
                .accessibilityValue(monthAndYearTitle)

                Spacer()

                HStack(spacing: 40) {
                    Button {
                        goPreviousWeek()
                    } label: {
                        Image(systemName: "chevron.left")
                            .font(.title3.weight(.medium))
                            .foregroundStyle(.primary)
                    }
                    .buttonStyle(.plain)
                    .containerShape(Rectangle())
                    .disabled(
                        currentWeekOffset == weekOffsetRange.lowerBound
                    )

                    Button {
                        goNextWeek()
                    } label: {
                        Image(systemName: "chevron.right")
                            .font(.title3.weight(.medium))
                            .foregroundStyle(.primary)
                    }
                    .buttonStyle(.plain)
                    .containerShape(Rectangle())
                    .disabled(
                        currentWeekOffset == weekOffsetRange.upperBound
                    )
                }
            }

            TabView(selection: $currentWeekOffset) {
                ForEach(weekOffsetRange, id: \.self) { offset in
                    WeekRow(
                        days: daysOfTheWeek(offset: offset),
                        selectedDate: $selectedDate
                    )
                    .tag(offset)
                }
            }
            .tabViewStyle(.page(indexDisplayMode: .never))
            .frame(height: 80)
        }
        .onAppear {
            updateVisibleWeek(
                for: selectedDate,
                animated: false
            )
        }
        .onChange(of: currentWeekOffset) {
            selectCorrespondingDayInVisibleWeek()
        }
        .onChange(of: selectedDate) {
            updateVisibleWeek(
                for: selectedDate,
                animated: false
            )
        }
        .sheet(isPresented: $isShowingDatePicker) {
            NavigationStack {
                DatePicker(
                    "Data",
                    selection: $pendingDate,
                    in: availableDateRange,
                    displayedComponents: .date
                )
                .datePickerStyle(.graphical)
                .labelsHidden()
                .environment(
                    \.locale,
                    Locale(identifier: "pt_BR")
                )
                .padding()
                .navigationTitle("Ir para uma data")
                .navigationBarTitleDisplayMode(.inline)
                .toolbar {
                    ToolbarItem(
                        placement: .cancellationAction
                    ) {
                        Button {
                            isShowingDatePicker = false
                        } label: {
                            Image(systemName: "xmark")
                        }
                    }

                    ToolbarItem(
                        placement: .confirmationAction
                    ) {
                        Button {
                            navigate(to: pendingDate)
                            isShowingDatePicker = false
                            
                        } label: {
                            Text("Ir")
                                .foregroundStyle(.white)
                        }
                        .buttonStyle(.borderedProminent)
                        .tint(.accent)
                    }
                }
            }
        }
    }

    private var monthAndYearTitle: String {
        let locale = Locale(identifier: "pt_BR")

        let month = selectedDate.formatted(
            .dateTime
                .month(.abbreviated)
                .locale(locale)
        )

        let year = selectedDate.formatted(
            .dateTime
                .year()
                .locale(locale)
        )

        let monthWithInitialCapital =
            String(month.prefix(1))
                .uppercased(with: locale)
            + String(month.dropFirst())

        return "\(monthWithInitialCapital) \(year)"
    }

    private var availableDateRange: ClosedRange<Date> {
        let firstDate =
            daysOfTheWeek(
                offset: weekOffsetRange.lowerBound
            ).first ?? Date()

        let lastDate =
            daysOfTheWeek(
                offset: weekOffsetRange.upperBound
            ).last ?? Date()

        let endOfLastDate =
            calendar.date(
                byAdding: .day,
                value: 1,
                to: lastDate
            )?.addingTimeInterval(-1) ?? lastDate

        return firstDate...endOfLastDate
    }

    private func goNextWeek() {
        guard
            currentWeekOffset < weekOffsetRange.upperBound
        else {
            return
        }

        currentWeekOffset += 1
    }

    private func goPreviousWeek() {
        guard
            currentWeekOffset > weekOffsetRange.lowerBound
        else {
            return
        }

        currentWeekOffset -= 1
    }

    private func daysOfTheWeek(
        offset: Int
    ) -> [Date] {
        let today = Date()

        guard
            let currentWeekStart =
                calendar.dateInterval(
                    of: .weekOfYear,
                    for: today
                )?.start,

            let weekStart =
                calendar.date(
                    byAdding: .weekOfYear,
                    value: offset,
                    to: currentWeekStart
                )
        else {
            return []
        }

        return (0..<7).compactMap { dayOffset in
            calendar.date(
                byAdding: .day,
                value: dayOffset,
                to: weekStart
            )
        }
    }

    private func navigate(to date: Date) {
        selectedDate = date

        updateVisibleWeek(
            for: date,
            animated: true
        )
    }

    private func updateVisibleWeek(
        for date: Date,
        animated: Bool
    ) {
        guard
            let currentWeekStart =
                calendar.dateInterval(
                    of: .weekOfYear,
                    for: Date()
                )?.start,

            let destinationWeekStart =
                calendar.dateInterval(
                    of: .weekOfYear,
                    for: date
                )?.start,

            let numberOfDays =
                calendar.dateComponents(
                    [.day],
                    from: currentWeekStart,
                    to: destinationWeekStart
                ).day
        else {
            return
        }

        let destinationOffset = numberOfDays / 7

        guard
            weekOffsetRange.contains(destinationOffset)
        else {
            return
        }

        if animated {
            withAnimation(.snappy(duration: 0.25)) {
                currentWeekOffset = destinationOffset
            }
        } else {
            currentWeekOffset = destinationOffset
        }
    }

    private func selectCorrespondingDayInVisibleWeek() {
        let visibleDays = daysOfTheWeek(
            offset: currentWeekOffset
        )

        let selectedDateIsVisible =
            visibleDays.contains { day in
                calendar.isDate(
                    day,
                    inSameDayAs: selectedDate
                )
            }

        guard !selectedDateIsVisible else {
            return
        }

        let selectedWeekday =
            calendar.component(
                .weekday,
                from: selectedDate
            )

        guard
            let correspondingDay =
                visibleDays.first(where: { day in
                    calendar.component(
                        .weekday,
                        from: day
                    ) == selectedWeekday
                })
        else {
            return
        }

        selectedDate = correspondingDay
    }
}

#Preview {
    @Previewable @State var selectedDate = Date()

    WeekCalendar(selectedDate: $selectedDate)
}
