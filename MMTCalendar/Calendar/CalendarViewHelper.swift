//
//  CalendarViewHelper.swift
//  MMTCalendar
//
//  Created by Arnab Hore on 28/06/22.
//

import Foundation
class CalendarViewHelper {
    let calendar: Calendar
    let priceList: [Price]
    let today: Date
    let selectedDates: [Date]
    let dateFormatter: DateFormatter
    
    init(calendar: Calendar, priceList: [Price], today: Date, selectedDays: [Day], dateFormatter: DateFormatter) {
        self.calendar = calendar
        self.priceList = priceList
        self.today = today
        self.selectedDates = selectedDays.map({ $0.date })
        self.dateFormatter = dateFormatter
    }

    func createMonthData(currentDate: Date) -> Month? {
        // Ask the calendar for the number of days in currentDate's month, then get the first day of that month.
        guard let numberOfDaysInMonth = calendar.range(
            of: .day,
            in: .month,
            for: currentDate)?.count,
              let firstDayOfMonth = calendar.date(
                from: calendar.dateComponents([.year, .month], from: currentDate))
        else { return nil }
        
        // Get the weekday value, a number between one and seven that represents which day of the week the first day of the month falls on.
        let firstDayWeekday = calendar.component(.weekday, from: firstDayOfMonth)
        
        // Use these values to create Month data and return it.
        return Month(
            numberOfDays: numberOfDaysInMonth,
            firstDay: firstDayOfMonth,
            firstDayWeekday: firstDayWeekday)
    }
    
    func generateDaysInMonth(currentDate: Date) -> [Day] {
        // Create the monthData for the month
        guard let monthData = createMonthData(currentDate: currentDate) else { return [] }
        
        let numberOfDaysInMonth = monthData.numberOfDays
        let offsetInInitialRow = monthData.firstDayWeekday
        let firstDayOfMonth = monthData.firstDay
        
        // If a month starts on a day other than Sunday, add the last few days from the previous month at the beginning.
        var days: [Day] = (1..<(numberOfDaysInMonth + offsetInInitialRow))
            .map { day in
                // Check if the current day in the loop is within the current month or part of the previous month.
                let isWithinDisplayedMonth = day >= offsetInInitialRow
                
                // Calculate the offset that day is from the first day of the month. If day is in the previous month, this value will be negative.
                let dayOffset =
                isWithinDisplayedMonth ?
                day - offsetInInitialRow :
                -(offsetInInitialRow - day)
                
                // Call generateDay function, which adds or subtracts an offset from a Date to produce a new one, and return its result.
                return generateDay(
                    dayOffset: dayOffset,
                    currentDate: firstDayOfMonth,
                    isWithinDisplayedMonth: isWithinDisplayedMonth)
            }
        
        // If the last day of the month doesn’t fall on a Saturday, add extra days to the calendar.
        days += generateStartOfNextMonth(firstDayOfDisplayedMonth: firstDayOfMonth)
        
        return days
    }
    
    func generateDay(dayOffset: Int, currentDate: Date, isWithinDisplayedMonth: Bool) -> Day {
        // Add or subtract an offset from a Date to produce a new one, and return its result.
        let date = calendar.date(
            byAdding: .day,
            value: dayOffset,
            to: currentDate) ?? currentDate
        
        let isSelected = selectedDates.contains(date)
        var isInSelectionRange = false
        if selectedDates.count == 2 {
            let sortedDate = selectedDates.sorted()
            isInSelectionRange = (sortedDate[0] ... sortedDate[1]).contains(date)
        }
        
        var todayPrice = ""
        let order = calendar.compare(date, to: today, toGranularity: .day)
        if order == .orderedSame || order == .orderedDescending {
            let fullDateFormatter = DateFormatter()
            fullDateFormatter.dateFormat = "yyyy-MM-dd"
            todayPrice = priceList.filter({ $0.date == fullDateFormatter.string(from: date) }).first?.price ?? ""
        }
        
        return Day(
            date: date,
            number: dateFormatter.string(from: date),
            price: todayPrice,
            isToday: calendar.isDate(date, inSameDayAs: today),
            isSelected: isSelected,
            isInSelectionRange: isInSelectionRange,
            isWithinDisplayedMonth: isWithinDisplayedMonth
        )
    }
    
    func generateStartOfNextMonth(firstDayOfDisplayedMonth: Date) -> [Day] {
        // Retrieve the last day of the displayed month.
        guard let lastDayInMonth = calendar.date(
            byAdding: DateComponents(month: 1, day: -1),
            to: firstDayOfDisplayedMonth)
        else { return [] }
        
        // Calculate the number of extra days that needs to be filled the last row of the calendar.
        let additionalDays = 7 - calendar.component(.weekday, from: lastDayInMonth)
        if additionalDays == 0 { return [] }
        
        // Create the Day data for the extra days
        let days: [Day] = (1...additionalDays)
            .map {
                generateDay(
                    dayOffset: $0,
                    currentDate: lastDayInMonth,
                    isWithinDisplayedMonth: false)
            }
        
        return days
    }
}
