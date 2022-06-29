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
        if self.selectedDays.count < 2 {
            // For round trip we can select at most 2 days.
            self.selectedDays.append(day.date)
            self.selectedIndexes.append(indexPath)
            
            if selectedIndexes.count == 2 {
                let sortedIndexes = selectedIndexes.sorted()
                for index in (sortedIndexes[0].row ... sortedIndexes[1].row) {
                    let cell = collectionView.cellForItem(at: IndexPath(item: index, section: 0)) as? CalendarCollectionViewCell
                    cell?.isInSelectionRange = true
                }
            }
        } else {
            // When 2 dates selected, and then user selects another one, then reset the selection.
            if selectedIndexes.count == 2 {
                let sortedIndexes = selectedIndexes.sorted()
                for index in (sortedIndexes[0].row ... sortedIndexes[1].row) {
                    let cell = collectionView.cellForItem(at: IndexPath(item: index, section: 0)) as? CalendarCollectionViewCell
                    cell?.isSelectedDay = false
                    cell?.isInSelectionRange = false
                }
            } else if selectedIndexes.count > 0 {
                let cell = collectionView.cellForItem(at: selectedIndexes[0]) as? CalendarCollectionViewCell
                cell?.isSelectedDay = false
            }
            self.selectedDays = [day.date]
            self.selectedIndexes = [indexPath]
        }
        
        let cell = collectionView.cellForItem(at: indexPath) as? CalendarCollectionViewCell
        cell?.isSelectedDay = true
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width = Int(collectionView.frame.width / 7)
        let height = Int(collectionView.frame.height) / numberOfWeeksInCurrentDate
        return CGSize(width: width, height: height)
    }
}

extension MMTCalendarView: CalendarButtonDelegate {
    func didTapPreviousMonth() {
        self.selectedIndexes = []
        self.currentDate = self.calendar.date(
            byAdding: .month,
            value: -1,
            to: self.currentDate
        ) ?? self.currentDate
    }
    
    func didTapNextMonth() {
        self.selectedIndexes = []
        self.currentDate = self.calendar.date(
            byAdding: .month,
            value: 1,
            to: self.currentDate
        ) ?? self.currentDate
    }
}
