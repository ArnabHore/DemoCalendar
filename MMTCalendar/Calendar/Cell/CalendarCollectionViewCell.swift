//
//  CalendarCollectionViewCell.swift
//  MMTCalendar
//
//  Created by Arnab Hore on 27/06/22.
//

import UIKit

final class CalendarCollectionViewCell: UICollectionViewCell {
    static let reuseIdentifier = String(describing: CalendarCollectionViewCell.self)
    
    private lazy var todayBackgroundView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.clipsToBounds = true
        view.backgroundColor = .systemOrange
        return view
    }()
    
    private lazy var selectionBackgroundView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.clipsToBounds = true
        view.backgroundColor = .systemBlue
        return view
    }()
    
    private lazy var numberLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textAlignment = .center
        label.font = UIFont.systemFont(ofSize: 18, weight: .medium)
        label.textColor = .label
        return label
    }()
    
    private lazy var priceLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textAlignment = .center
        label.font = UIFont.systemFont(ofSize: 12, weight: .regular)
        label.textColor = .secondaryLabel
        return label
    }()
    
    var day: Day? {
        didSet {
            guard let day = day else { return }
            numberLabel.text = day.number
            priceLabel.text = day.price
            updateCellStatus()
        }
    }
    
    var isSelectedDay: Bool = false {
        didSet {
            day?.isSelected = isSelectedDay
            updateCellStatus()
        }
    }
    
    var isInSelectionRange: Bool = false {
        didSet {
            day?.isInSelectionRange = isInSelectionRange
            updateCellStatus()
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        contentView.addSubview(todayBackgroundView)
        contentView.addSubview(selectionBackgroundView)
        contentView.addSubview(numberLabel)
        contentView.addSubview(priceLabel)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
                
        self.layer.borderColor = UIColor.systemGray4.cgColor
        self.layer.borderWidth = 0.5

        numberLabel.centerYAnchor.constraint(equalTo: centerYAnchor, constant: -10).isActive = true
        numberLabel.centerXAnchor.constraint(equalTo: centerXAnchor).isActive = true
                
        priceLabel.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -5).isActive = true
        priceLabel.leadingAnchor.constraint(equalTo: leadingAnchor).isActive = true
        priceLabel.trailingAnchor.constraint(equalTo: trailingAnchor).isActive = true

        todayBackgroundView.leadingAnchor.constraint(equalTo: self.leadingAnchor).isActive = true
        todayBackgroundView.trailingAnchor.constraint(equalTo: self.trailingAnchor).isActive = true
        todayBackgroundView.topAnchor.constraint(equalTo: self.topAnchor).isActive = true
        todayBackgroundView.bottomAnchor.constraint(equalTo: self.bottomAnchor).isActive = true

        selectionBackgroundView.leadingAnchor.constraint(equalTo: self.leadingAnchor).isActive = true
        selectionBackgroundView.trailingAnchor.constraint(equalTo: self.trailingAnchor).isActive = true
        selectionBackgroundView.topAnchor.constraint(equalTo: self.topAnchor).isActive = true
        selectionBackgroundView.bottomAnchor.constraint(equalTo: self.bottomAnchor).isActive = true
    }
}

private extension CalendarCollectionViewCell {
    // Apply a different style to the cell for today and based on the selection status of the day.
    func updateCellStatus() {
        guard let day = day else { return }
        
        if day.isSelected {
            applySelectionStyle()
        } else if day.isInSelectionRange {
            applySelectionRangeStyle()
        } else if day.isToday {
            applyTodayStyle()
        } else {
            applyDefaultStyle(isWithinDisplayedMonth: day.isWithinDisplayedMonth)
        }
    }
    
    // Apply when it is today
    func applyTodayStyle() {
        numberLabel.textColor = .white
        priceLabel.textColor = .white
        todayBackgroundView.isHidden = false
        selectionBackgroundView.isHidden = true
    }
    
    // Apply when the user selects the cell
    func applySelectionStyle() {
        numberLabel.textColor = .white
        priceLabel.textColor = .white
        selectionBackgroundView.backgroundColor = .systemBlue
        todayBackgroundView.isHidden = true
        selectionBackgroundView.isHidden = false
    }
    
    // Apply when the cell is inside 2 selected dates
    func applySelectionRangeStyle() {
        numberLabel.textColor = .white
        priceLabel.textColor = .white
        selectionBackgroundView.backgroundColor = .systemBlue.withAlphaComponent(0.5)
        todayBackgroundView.isHidden = true
        selectionBackgroundView.isHidden = false
    }

    // Apply a default style to the cell.
    func applyDefaultStyle(isWithinDisplayedMonth: Bool) {
        numberLabel.textColor = isWithinDisplayedMonth ? .label : .secondaryLabel
        priceLabel.textColor = .secondaryLabel
        todayBackgroundView.isHidden = true
        selectionBackgroundView.isHidden = true
    }
}
