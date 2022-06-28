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
            days = self.generateDaysInMonth(currentDate: currentDate)
            collectionView.reloadData()
            headerView.currentData = currentDate
        }
    }
    
    lazy var days = generateDaysInMonth(currentDate: currentDate)
    
    var numberOfWeeksInCurrentDate: Int {
        calendar.range(of: .weekOfMonth, in: .month, for: currentDate)?.count ?? 0
    }
    
    //private let selectedDateChanged: ((Date) -> Void)
    let calendar = Calendar.current
    let selectedDate: Date
    
    lazy var dateFormatter: DateFormatter = {
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
    
    private func setup() {
        //self.selectedDateChanged = selectedDateChanged
        
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
        
        headerView.currentData = currentDate
        headerView.calendarButtonDelegate = self
    }
}
