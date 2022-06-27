//
//  HomeViewController.swift
//  MMTCalendar
//
//  Created by Arnab Hore on 27/06/22.
//

import UIKit

final class HomeViewController: UIViewController {
    @IBOutlet weak var calendarView: UIView!

    private var collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.minimumLineSpacing = 0
        layout.minimumInteritemSpacing = 0
        
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.isScrollEnabled = false
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        
        collectionView.dataSource = self
        collectionView.delegate = self

        return collectionView
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        calendarView.addSubview(collectionView)
        
        calendarView.addConstraint(NSLayoutConstraint(item: collectionView, attribute: .leading, relatedBy: .equal, toItem: calendarView, attribute: .leading, multiplier: 1, constant: 0))
        calendarView.addConstraint(NSLayoutConstraint(item: collectionView, attribute: .trailing, relatedBy: .equal, toItem: calendarView, attribute: .trailing, multiplier: 1, constant: 0))
        calendarView.addConstraint(NSLayoutConstraint(item: collectionView, attribute: .top, relatedBy: .equal, toItem: calendarView, attribute: .top, multiplier: 1, constant: 0))
        calendarView.addConstraint(NSLayoutConstraint(item: collectionView, attribute: .bottom, relatedBy: .equal, toItem: calendarView, attribute: .bottom, multiplier: 1, constant: 0))

        collectionView.register(CalendarCollectionViewCell.self, forCellWithReuseIdentifier: CalendarCollectionViewCell.reuseIdentifier)
    }
}
