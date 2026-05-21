//
//  ShopEvent.swift
//  koin
//
//  Created by 김나훈 on 6/15/24.
//

import Foundation

struct ShopEvent {
    var isExpanded: Bool = false
    var currentPage: Int?
    
    let shopId: Int
    let shopName: String
    let title, content: String
    var thumbnailImages: [String]?
    let startDate, endDate: String
}
