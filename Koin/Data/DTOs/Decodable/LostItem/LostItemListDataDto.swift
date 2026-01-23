//
//  LostItemListDataDto.swift
//  koin
//
//  Created by 홍기정 on 1/21/26.
//

import Foundation

struct LostItemListDataDto: Decodable {
    let id, boardID: Int
    let type: LostItemType
    let category, foundPlace, foundDate: String
    let content: String?
    let author: String
    let registeredAt: String
    let isReported, isFound: Bool
    
    enum CodingKeys: String, CodingKey {
        case id
        case boardID = "board_id"
        case type, category
        case foundPlace = "found_place"
        case foundDate = "found_date"
        case content, author
        case registeredAt = "registered_at"
        case isReported = "is_reported"
        case isFound = "is_found"
    }
}

extension LostItemListDataDto {
    
    func toDomain() -> LostItemListData {
        return LostItemListData(
            id: self.id,
            type: self.type,
            category: self.category,
            foundPlace: self.foundPlace,
            foundDate: self.foundDate,
            content: self.content,
            author: self.author,
            registeredAt: self.registeredAt,
            isReported: self.isReported,
            isFound: self.isFound)
    }
}
