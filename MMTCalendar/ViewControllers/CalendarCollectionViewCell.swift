//
//  CalendarCollectionViewCell.swift
//  MMTCalendar
//
//  Created by Arnab Hore on 27/06/22.
//

import UIKit

final class CalendarCollectionViewCell: UICollectionViewCell {
    static let reuseIdentifier = String(describing: CalendarCollectionViewCell.self)
    
    private lazy var selectionBackgroundView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.clipsToBounds = true
        view.backgroundColor = .systemTeal
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
    
    var day: Day? {
        didSet {
            guard let day = day else { return }
            
            numberLabel.text = day.number
            accessibilityLabel = accessibilityDateFormatter.string(from: day.date)
            updateSelectionStatus()
        }
    }
    
    override init(frame: CGRect) {
      super.init(frame: frame)

      isAccessibilityElement = true
      accessibilityTraits = .button

      contentView.addSubview(selectionBackgroundView)
      contentView.addSubview(numberLabel)
    }

    required init?(coder: NSCoder) {
      fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        let size: CGFloat = 45
        
        numberLabel.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true
        numberLabel.centerXAnchor.constraint(equalTo: centerXAnchor).isActive = true
        
        selectionBackgroundView.centerYAnchor.constraint(equalTo: numberLabel.centerYAnchor).isActive = true
        selectionBackgroundView.centerXAnchor.constraint(equalTo: numberLabel.centerXAnchor).isActive = true
        selectionBackgroundView.widthAnchor.constraint(equalToConstant: size).isActive = true
        selectionBackgroundView.heightAnchor.constraint(equalToConstant: size).isActive = true
        
        selectionBackgroundView.layer.cornerRadius = size / 2
    }
}

private extension CalendarDateCollectionViewCell {
  // 1
  func updateSelectionStatus() {
    guard let day = day else { return }

    if day.isSelected {
      applySelectedStyle()
    } else {
      applyDefaultStyle(isWithinDisplayedMonth: day.isWithinDisplayedMonth)
    }
  }

  // 2
  var isSmallScreenSize: Bool {
    let isCompact = traitCollection.horizontalSizeClass == .compact
    let smallWidth = UIScreen.main.bounds.width <= 350
    let widthGreaterThanHeight = UIScreen.main.bounds.width > UIScreen.main.bounds.height

    return isCompact && (smallWidth || widthGreaterThanHeight)
  }

  // 3
  func applySelectedStyle() {
    accessibilityTraits.insert(.selected)
    accessibilityHint = nil

    numberLabel.textColor = isSmallScreenSize ? .systemRed : .white
    selectionBackgroundView.isHidden = isSmallScreenSize
  }

  // 4
  func applyDefaultStyle(isWithinDisplayedMonth: Bool) {
    accessibilityTraits.remove(.selected)
    accessibilityHint = "Tap to select"

    numberLabel.textColor = isWithinDisplayedMonth ? .label : .secondaryLabel
    selectionBackgroundView.isHidden = true
  }
}
