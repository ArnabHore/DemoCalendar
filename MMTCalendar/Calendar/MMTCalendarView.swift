//
//  MMTCalendarView.swift
//  MMTCalendar
//
//  Created by Arnab Hore on 28/06/22.
//

import UIKit

class MMTCalendarView: UIView {
    private var collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.minimumLineSpacing = 0
        layout.minimumInteritemSpacing = 0
        
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.isScrollEnabled = false
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        
        return collectionView
    }()
    
    private var currentDate: Date {
        didSet {
            days = self.generateDaysInMonth(currentDate: currentDate)
            collectionView.reloadData()
        }
    }
    
    private lazy var days = generateDaysInMonth(currentDate: currentDate)
    
    private var numberOfWeeksInCurrentDate: Int {
        calendar.range(of: .weekOfMonth, in: .month, for: currentDate)?.count ?? 0
    }
    
    //private let selectedDateChanged: ((Date) -> Void)
    private let calendar = Calendar.current
    private let selectedDate: Date
    
    private lazy var dateFormatter: DateFormatter = {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "d"
        return dateFormatter
    }()
    
    override init(frame: CGRect) {
        self.selectedDate = Date()
        self.currentDate = Date()
        
        super.init(frame: frame)
        self.setup()
    }
    
    required init?(coder: NSCoder) {
        self.selectedDate = Date()
        self.currentDate = Date()
        
        super.init(coder: coder)
        self.setup()
    }
    
    func setup() {
        //self.selectedDateChanged = selectedDateChanged
        
        self.addSubview(collectionView)
        
        self.addConstraint(NSLayoutConstraint(item: collectionView, attribute: .leading, relatedBy: .equal, toItem: self, attribute: .leading, multiplier: 1, constant: 0))
        self.addConstraint(NSLayoutConstraint(item: collectionView, attribute: .trailing, relatedBy: .equal, toItem: self, attribute: .trailing, multiplier: 1, constant: 0))
        self.addConstraint(NSLayoutConstraint(item: collectionView, attribute: .top, relatedBy: .equal, toItem: self, attribute: .top, multiplier: 1, constant: 0))
        self.addConstraint(NSLayoutConstraint(item: collectionView, attribute: .bottom, relatedBy: .equal, toItem: self, attribute: .bottom, multiplier: 1, constant: 0))
        
        collectionView.register(CalendarCollectionViewCell.self, forCellWithReuseIdentifier: CalendarCollectionViewCell.reuseIdentifier)
        
        collectionView.dataSource = self
        collectionView.delegate = self
    }
}

extension MMTCalendarView: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        days.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: CalendarCollectionViewCell.reuseIdentifier, for: indexPath) as? CalendarCollectionViewCell else { return UICollectionViewCell() }
        let day = days[indexPath.row]
        cell.day = day
        return cell
    }
}

extension MMTCalendarView: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let day = days[indexPath.row]
        //        selectedDateChanged(day.date)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width = Int(collectionView.frame.width / 7)
        let height = Int(collectionView.frame.height) / numberOfWeeksInCurrentDate
        return CGSize(width: width, height: height)
    }
}

extension MMTCalendarView {
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
        
        return Day(
            date: date,
            number: dateFormatter.string(from: date),
            isSelected: calendar.isDate(date, inSameDayAs: selectedDate),
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
