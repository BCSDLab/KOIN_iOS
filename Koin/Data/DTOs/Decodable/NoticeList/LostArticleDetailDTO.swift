//
//  LostArticleDetailDTO.swift
//  koin
//
//  Created by 김나훈 on 1/15/25.
//

import Foundation

struct LostArticleDetailDTO: Decodable {
    let id, boardId: Int
    let type: LostItemType?
    let category, foundPlace, foundDate: String
    let content: String?
    let author: String
    let images: [Image]?
    let isCouncil: Bool?
    let isMine: Bool?
    let prevId, nextId: Int?
    let registeredAt, updatedAt: String

    enum CodingKeys: String, CodingKey {
        case id
        case boardId = "board_id"
        case category
        case type
        case foundPlace = "found_place"
        case foundDate = "found_date"
        case content, author, images
        case prevId = "prev_id"
        case nextId = "next_id"
        case registeredAt = "registered_at"
        case updatedAt = "updated_at"
        case isCouncil = "is_council"
        case isMine = "is_mine"
    }
}

struct Image: Decodable {
    let id: Int
    let imageUrl: String

    enum CodingKeys: String, CodingKey {
        case id
        case imageUrl = "image_url"
    }
}
