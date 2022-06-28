//
//  CalendarView+Delegate.swift
//  MMTCalendar
//
//  Created by Arnab Hore on 28/06/22.
//

import UIKit

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

extension MMTCalendarView: CalendarButtonDelegate {
    func didTapPreviousMonth() {
        self.currentDate = self.calendar.date(
            byAdding: .month,
            value: -1,
            to: self.currentDate
        ) ?? self.currentDate
    }
    
    func didTapNextMonth() {
        self.currentDate = self.calendar.date(
            byAdding: .month,
            value: 1,
            to: self.currentDate
        ) ?? self.currentDate
    }
}
