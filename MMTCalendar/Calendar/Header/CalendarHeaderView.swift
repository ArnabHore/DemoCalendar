//
//  CalendarHeaderView.swift
//  MMTCalendar
//
//  Created by Arnab Hore on 28/06/22.
//

import UIKit

protocol CalendarButtonDelegate: AnyObject {
    func didTapPreviousMonth()
    func didTapNextMonth()
}

class CalendarHeaderView: UIView {
    lazy var monthLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = .systemFont(ofSize: 26, weight: .bold)
        label.textAlignment = .center
        label.text = "Month"
        return label
    }()
    
    lazy var dayOfWeekStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.distribution = .fillEqually
        return stackView
    }()
    
    lazy var separatorView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = UIColor.label.withAlphaComponent(0.2)
        return view
    }()
    
    lazy var previousMonthButton: UIButton = {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        if let chevronImage = UIImage(systemName: "chevron.left.circle.fill") {
            button.setImage(chevronImage, for: .normal)
        } else {
            button.setTitle("Previous", for: .normal)
        }
        button.addTarget(self, action: #selector(didTapPreviousMonthButton), for: .touchUpInside)
        return button
    }()
    
    lazy var nextMonthButton: UIButton = {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        if let chevronImage = UIImage(systemName: "chevron.right.circle.fill") {
            button.setImage(chevronImage, for: .normal)
        } else {
            button.setTitle("Next", for: .normal)
        }
        button.addTarget(self, action: #selector(didTapNextMonthButton), for: .touchUpInside)
        return button
    }()
    
    private lazy var dateFormatter: DateFormatter = {
        let dateFormatter = DateFormatter()
        dateFormatter.calendar = Calendar(identifier: .gregorian)
        dateFormatter.locale = Locale.autoupdatingCurrent
        dateFormatter.setLocalizedDateFormatFromTemplate("MMMM y")
        return dateFormatter
    }()
    
    var currentDate = Date() {
        didSet {
            monthLabel.text = dateFormatter.string(from: currentDate)
        }
    }
    
    weak var calendarButtonDelegate: CalendarButtonDelegate?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.setup()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        self.setup()
    }
    
    private func setup() {
        self.translatesAutoresizingMaskIntoConstraints = false
        
        self.addSubview(monthLabel)
        self.addSubview(previousMonthButton)
        self.addSubview(nextMonthButton)
        self.addSubview(dayOfWeekStackView)
        self.addSubview(separatorView)
        
        // Create day name in the header
        let dayNames = Calendar.current.shortWeekdaySymbols
        for dayName in dayNames {
            let dayLabel = UILabel()
            dayLabel.font = .systemFont(ofSize: 12, weight: .bold)
            dayLabel.textColor = .secondaryLabel
            dayLabel.textAlignment = .center
            dayLabel.text = dayName
            
            dayOfWeekStackView.addArrangedSubview(dayLabel)
        }
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        monthLabel.topAnchor.constraint(equalTo: self.topAnchor, constant: 5).isActive = true
        monthLabel.bottomAnchor.constraint(equalTo: self.dayOfWeekStackView.topAnchor).isActive = true
        monthLabel.leadingAnchor.constraint(equalTo: self.previousMonthButton.trailingAnchor, constant: 5).isActive = true
        monthLabel.trailingAnchor.constraint(equalTo: self.nextMonthButton.leadingAnchor, constant: -5).isActive = true
        monthLabel.centerXAnchor.constraint(equalTo: self.centerXAnchor).isActive = true
        
        previousMonthButton.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 5).isActive = true
        previousMonthButton.centerYAnchor.constraint(equalTo: self.monthLabel.centerYAnchor).isActive = true
        previousMonthButton.heightAnchor.constraint(equalToConstant: 24).isActive = true
        previousMonthButton.widthAnchor.constraint(equalToConstant: 24).isActive = true
        
        nextMonthButton.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -5).isActive = true
        nextMonthButton.centerYAnchor.constraint(equalTo: self.monthLabel.centerYAnchor).isActive = true
        nextMonthButton.heightAnchor.constraint(equalToConstant: 24).isActive = true
        nextMonthButton.widthAnchor.constraint(equalToConstant: 24).isActive = true
        
        dayOfWeekStackView.leadingAnchor.constraint(equalTo: self.leadingAnchor).isActive = true
        dayOfWeekStackView.trailingAnchor.constraint(equalTo: self.trailingAnchor).isActive = true
        dayOfWeekStackView.bottomAnchor.constraint(equalTo: self.separatorView.bottomAnchor, constant: -5).isActive = true
        
        separatorView.leadingAnchor.constraint(equalTo: self.leadingAnchor).isActive = true
        separatorView.trailingAnchor.constraint(equalTo: self.trailingAnchor).isActive = true
        separatorView.bottomAnchor.constraint(equalTo: self.bottomAnchor).isActive = true
        separatorView.heightAnchor.constraint(equalToConstant: 1).isActive = true
    }
    
    @objc func didTapPreviousMonthButton() {
        calendarButtonDelegate?.didTapPreviousMonth()
    }
    
    @objc func didTapNextMonthButton() {
        calendarButtonDelegate?.didTapNextMonth()
    }
}
