//
//  HomeViewController.swift
//  MMTCalendar
//
//  Created by Arnab Hore on 27/06/22.
//

import UIKit

class HomeViewController: UIViewController {
    @IBOutlet weak var calendarView: MMTCalendarView!
    @IBOutlet weak var infoLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "MMT Calendar"
        calendarView.delegate = self
    }
}

extension HomeViewController: MMTCalendarDelegate {
    func didSelectDate(startDate: Date, endDate: Date?) {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd MMM yyyy"
        
        var endDateString = ""
        if let endDate = endDate {
            let order = Calendar.current.compare(startDate, to: endDate, toGranularity: .day)
            if order != .orderedSame {
                endDateString = " - " + dateFormatter.string(from: endDate)
            }
        }
        self.infoLabel.text = dateFormatter.string(from: startDate) + endDateString
        self.infoLabel.textColor = .label
    }
    
    func showError(message: String) {
        self.infoLabel.text = message
        self.infoLabel.textColor = .systemRed
    }
}
