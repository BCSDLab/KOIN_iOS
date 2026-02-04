//
//  LostItemListData.swift
//  koin
//
//  Created by 홍기정 on 1/18/26.
//

import Foundation

struct LostItemListData {
    let id: Int
    let type: LostItemType
    var category: String
    var foundPlace: String?
    var foundDate: String
    var content: String?
    let author: String
    let registeredAt: String
    var isReported: Bool
    var isFound: Bool
}

extension LostItemListData {
    
    init(from data: LostItemData) {
        self.id = data.id
        self.type = data.type
        self.category = data.category
        self.foundPlace = data.foundPlace
        self.foundDate = data.foundDate
        self.content = data.content
        self.author = data.author
        self.registeredAt = data.registeredAt
        self.isReported = false
        self.isFound = data.isFound
    }
}
