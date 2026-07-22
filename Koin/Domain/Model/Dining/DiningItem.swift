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
    let soldoutAt, changedAt: String?
    let imageUrl: String?
    var likes: Int
    var isLiked: Bool
    let date: String
    
    mutating func increaseLike() {
        likes += 1
        isLiked.toggle()
    }
    
    mutating func decreaseLike() {
        likes -= 1
        isLiked.toggle()
    }
    
    func toShareDiningItem() -> ShareDiningMenu {
        let formattedDate = dateStringToFormattedString(dateString: date)
        return ShareDiningMenu(menuList: menu, imageUrl: imageUrl, date: formattedDate, type: type, place: place)
    }
    
    private func dateStringToFormattedString(dateString: String) -> String {
        let inputFormatter = DateFormatter()
        inputFormatter.dateFormat = "yyyy-MM-dd"
        
        if let date = inputFormatter.date(from: dateString) {
            return date.formatDateToYYMMDD()
        } else {
            return dateString
        }
    }
    
}
