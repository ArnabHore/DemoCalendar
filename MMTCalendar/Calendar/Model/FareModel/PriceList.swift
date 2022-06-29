//
//  PriceList.swift
//  MMTCalendar
//
//  Created by Arnab Hore on 29/06/22.
//

import Foundation

struct PriceList: Codable {
    let success: Bool?
    let data: [Price]?
}

struct Price: Codable {
    let date: String?
    let price: String?
}
