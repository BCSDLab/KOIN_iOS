//
//  HomeDiningItem.swift
//  koin
//
//  Created by 홍기정 on 6/3/26.
//

import Foundation

struct HomeDiningItem: Equatable, Identifiable {
    let id: Int
    let placeName: String
    let timeText: String
    let priceText: String?
    let kcalText: String?
    let menu: [String]
}
