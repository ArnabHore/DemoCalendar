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
        let order = calendar.compare(day.date, to: today, toGranularity: .day)
        guard order == .orderedSame || order == .orderedDescending else { return }

        if self.selectedDays.count < 2 {
            // For round trip we can select at most 2 days.
            self.selectedDays.append(day)
            self.selectedDays = selectedDays.sorted(by: { $0.date < $1.date })
            
            if selectedDays.count == 2 {
                let startIndex = days.firstIndex(of: selectedDays[0]) ?? 0
                let endIndex = days.firstIndex(of: selectedDays[1]) ?? (days.count - 1)
                
                for index in (startIndex ... endIndex) {
                    let cell = collectionView.cellForItem(at: IndexPath(item: index, section: 0)) as? CalendarCollectionViewCell
                    cell?.isInSelectionRange = true
                }
            }
        } else {
            // When 2 dates selected, and then user selects another one, then reset previous selection.
            if selectedDays.count == 2 {
                let startIndex = days.firstIndex(of: selectedDays[0]) ?? 0
                let endIndex = days.firstIndex(of: selectedDays[1]) ?? (days.count - 1)

                for index in (startIndex ... endIndex) {
                    let cell = collectionView.cellForItem(at: IndexPath(item: index, section: 0)) as? CalendarCollectionViewCell
                    cell?.isSelectedDay = false
                    cell?.isInSelectionRange = false
                }
            } else if selectedDays.count == 1 {
                let item = days.firstIndex(of: selectedDays[0]) ?? 0
                let cell = collectionView.cellForItem(at: IndexPath(item: item, section: 0)) as? CalendarCollectionViewCell
                cell?.isSelectedDay = false
            }
            self.selectedDays = [day]
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
