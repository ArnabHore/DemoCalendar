//
//  Day.swift
//  MMTCalendar
//
//  Created by Arnab Hore on 27/06/22.
//

import Foundation
struct Day: Equatable {
    let date: Date
    let number: String
    let price: String
    let isToday: Bool
    var isSelected: Bool
    var isInSelectionRange: Bool
    let isWithinDisplayedMonth: Bool
}
