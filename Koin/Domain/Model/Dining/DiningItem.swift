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
    let image: DiningImage
    let date: Date
    
    func toShareDiningItem() -> ShareDiningMenu {
        return ShareDiningMenu(menuList: menu, imageUrl: image.imageUrl, date: date.formatDateToYYMMDD(), type: type, place: place)
    }
    
}

extension DiningItem {
    var diningPriceText: String? {
        guard let price = priceCash ?? priceCard, price > 0 else { return nil }
        return "₩\(price.formatted(.number))"
    }

    var kcalPriceText: String {
        let kcalText = "\(kcal)kcal"
        let priceText = [priceCard, priceCash].compactMap { price in
            if let price {
                return "\(price)원"
            } else {
                return nil
            }
        }
        .joined(separator: "/")

        return priceText.isEmpty
        ? kcalText
        : [kcalText, priceText].joined(separator: " • ")
    }
}
