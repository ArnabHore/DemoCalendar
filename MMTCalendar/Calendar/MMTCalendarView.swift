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
    private let headerView = CalendarHeaderView()
    
    var currentDate: Date {
        didSet {
            let helper = CalendarViewHelper(calendar: calendar, priceList: priceList, today: today, selectedDays: selectedDays, dateFormatter: dateFormatter)
            days = helper.generateDaysInMonth(currentDate: currentDate)
            collectionView.reloadData()
            headerView.currentDate = currentDate
        }
    }
    
    var days: [Day] = []
    
    var numberOfWeeksInCurrentDate: Int {
        calendar.range(of: .weekOfMonth, in: .month, for: currentDate)?.count ?? 0
    }
    
    let calendar = Calendar.current
    let today: Date
    
    // To store selected days, useful when selected dates are not in current months
    var selectedDays: [Day] = []
        
    var dateFormatter: DateFormatter = {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "d"
        return dateFormatter
    }()
    
    var priceList: [Price] = []
    
    override init(frame: CGRect) {
        self.today = Date()
        self.currentDate = Date()
        
        super.init(frame: frame)
        self.setup()
    }
    
    required init?(coder: NSCoder) {
        self.today = Date()
        self.currentDate = Date()
        
        super.init(coder: coder)
        self.setup()
    }
    
    private func setup() {
        self.getPriceList()
        let helper = CalendarViewHelper(calendar: calendar, priceList: priceList, today: today, selectedDays: selectedDays, dateFormatter: dateFormatter)
        self.days = helper.generateDaysInMonth(currentDate: currentDate)
        
        self.layer.borderColor = UIColor.systemGray3.cgColor
        self.layer.borderWidth = 0.5
        
        self.addSubview(collectionView)
        self.addSubview(headerView)
        
        collectionView.leadingAnchor.constraint(equalTo: self.leadingAnchor).isActive = true
        collectionView.trailingAnchor.constraint(equalTo: self.trailingAnchor).isActive = true
        collectionView.topAnchor.constraint(equalTo: self.headerView.bottomAnchor).isActive = true
        collectionView.bottomAnchor.constraint(equalTo: self.bottomAnchor).isActive = true
        
        headerView.leadingAnchor.constraint(equalTo: collectionView.leadingAnchor).isActive = true
        headerView.trailingAnchor.constraint(equalTo: collectionView.trailingAnchor).isActive = true
        headerView.topAnchor.constraint(equalTo: self.topAnchor).isActive = true
        headerView.heightAnchor.constraint(equalToConstant: 85).isActive = true
        
        collectionView.register(CalendarCollectionViewCell.self, forCellWithReuseIdentifier: CalendarCollectionViewCell.reuseIdentifier)
        
        collectionView.dataSource = self
        collectionView.delegate = self
        
        headerView.currentDate = currentDate
        headerView.calendarButtonDelegate = self
    }
    
    func getPriceList() {
        guard let url = Bundle.main.url(forResource: "Price", withExtension: "json"),
              let data = try? Data(contentsOf: url),
              let response = try? JSONDecoder().decode(PriceList.self, from: data)
        else { return }
        self.priceList = response.data ?? []
    }
}
