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
    let timeText: String?
    let priceText: String?
    let kcalText: String?
    let menu: String
}

extension HomeDiningItem {
    init(_ diningItem: DiningItem, timeText: String?) {
        self.init(
            id: diningItem.id,
            placeName: diningItem.place.rawValue,
            timeText: timeText,
            priceText: diningItem.diningPriceText,
            kcalText: "\(diningItem.kcal)kcal",
            menu: diningItem.menu.joined(separator: " · ")
        )
    }
}
