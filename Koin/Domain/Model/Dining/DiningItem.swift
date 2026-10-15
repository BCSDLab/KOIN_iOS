//
//  DiningList.swift
//  koin
//
//  Created by 김나훈 on 6/9/24.
//

import Foundation

struct DiningItem {
    let id: Int
    let type: DiningType
    let place: DiningPlace
    let priceCard, priceCash: Int?
    let kcal: Int
    let menu: [String]
    let isSoldOut, isChanged: Bool
    let imageUrl: String?
    let date: Date
    
    func toShareDiningItem() -> ShareDiningMenu {
        return ShareDiningMenu(menuList: menu, imageUrl: imageUrl, date: date.formatDateToYYMMDD(), type: type, place: place)
    }
    
}

extension DiningItem {
    var image: DiningImage {
        DiningImage(from: imageUrl, place: place, type: type, isWeekend: date.isWeekend)
    }

    var diningPriceText: String? {
        guard let price = priceCash ?? priceCard, price > 0 else { return nil }
        return "₩\(price.formatted(.number))"
    }
}
