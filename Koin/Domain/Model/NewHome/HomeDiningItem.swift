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

extension HomeDiningItem {
    init(_ diningItem: DiningItem) {
        self.init(
            id: diningItem.id,
            placeName: diningItem.place.rawValue,
            timeText: diningItem.type.newHomeDiningTimeText,
            priceText: diningItem.newHomeDiningPriceText,
            kcalText: "\(diningItem.kcal)kcal",
            menu: diningItem.menu
        )
    }
}
