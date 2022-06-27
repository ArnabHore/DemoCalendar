//
//  HomeViewController.swift
//  MMTCalendar
//
//  Created by Arnab Hore on 27/06/22.
//

import UIKit

class HomeViewController: UIViewController {
    @IBOutlet weak var calendarView: UIView!
    
    private var collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.minimumLineSpacing = 0
        layout.minimumInteritemSpacing = 0
        
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.isScrollEnabled = false
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        
        return collectionView
    }()
    
    private var currentData: Date {
        didSet {
            days = self.generateDaysInMonth(currentDate: currentData)
            collectionView.reloadData()
        }
    }
    
    private lazy var days = generateDaysInMonth(currentDate: currentData)
    
    private var numberOfWeeksInCurrentDate: Int {
        calendar.range(of: .weekOfMonth, in: .month, for: currentData)?.count ?? 0
    }
    
    private let selectedDateChanged: ((Date) -> Void)
    private let calendar = Calendar.current
    private let selectedDate: Date
    
    private lazy var dateFormatter: DateFormatter = {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "d"
        return dateFormatter
    }()
    
    init(currentData: Date, selectedDateChanged: @escaping ((Date) -> Void)) {
        self.selectedDate = currentData
        self.currentData = currentData
        self.selectedDateChanged = selectedDateChanged
        
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        calendarView.addSubview(collectionView)
        
        calendarView.addConstraint(NSLayoutConstraint(item: collectionView, attribute: .leading, relatedBy: .equal, toItem: calendarView, attribute: .leading, multiplier: 1, constant: 0))
        calendarView.addConstraint(NSLayoutConstraint(item: collectionView, attribute: .trailing, relatedBy: .equal, toItem: calendarView, attribute: .trailing, multiplier: 1, constant: 0))
        calendarView.addConstraint(NSLayoutConstraint(item: collectionView, attribute: .top, relatedBy: .equal, toItem: calendarView, attribute: .top, multiplier: 1, constant: 0))
        calendarView.addConstraint(NSLayoutConstraint(item: collectionView, attribute: .bottom, relatedBy: .equal, toItem: calendarView, attribute: .bottom, multiplier: 1, constant: 0))
        
        collectionView.register(CalendarCollectionViewCell.self, forCellWithReuseIdentifier: CalendarCollectionViewCell.reuseIdentifier)
        
        collectionView.dataSource = self
        collectionView.delegate = self
    }
}
extension HomeViewController: UICollectionViewDataSource {
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


extension HomeViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let day = days[indexPath.row]
        selectedDateChanged(day.date)
        dismiss(animated: true, completion: nil)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width = Int(collectionView.frame.width / 7)
        let height = Int(collectionView.frame.height) / numberOfWeeksInCurrentDate
        return CGSize(width: width, height: height)
    }
}

extension HomeViewController {
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
