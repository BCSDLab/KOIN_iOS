//
//  LostItemDataDto.swift
//  koin
//
//  Created by 홍기정 on 1/22/26.
//

import Foundation

struct LostItemDataDto: Decodable {
    let id: Int
    let boardId: Int
    let type: LostItemType
    let category: String
    let foundPlace: String?
    let foundDate: String
    let content: String?
    let author: String
    let organization: Organization?
    let isMine: Bool
    let isFound: Bool
    let images: [Image]
    let prevId: Int?
    let nextId: Int?
    let registeredAt: String
    let updatedAt: String

    enum CodingKeys: String, CodingKey {
        case id
        case boardId = "board_id"
        case type
        case category
        case foundPlace = "found_place"
        case foundDate = "found_date"
        case content
        case author
        case organization
        case isMine = "is_mine"
        case isFound = "is_found"
        case images
        case prevId = "prev_id"
        case nextId = "next_id"
        case registeredAt = "registered_at"
        case updatedAt = "updated_at"
    }
}

struct Organization: Decodable {
    let name: String
    let location: String
    
    enum CodingKeys: String, CodingKey {
        case name
        case location
    }
}


extension LostItemDataDto {
    
    func toDomain() -> LostItemData {
        return LostItemData(
            id: self.id,
            type: self.type,
            category: self.category,
            foundPlace: self.foundPlace,
            foundDate: self.foundDate,
            content: self.content,
            author: self.author,
            organization: self.organization,
            isMine: self.isMine,
            isFound: self.isFound,
            images: self.images,
            registeredAt: self.registeredAt
        )
    }
}
