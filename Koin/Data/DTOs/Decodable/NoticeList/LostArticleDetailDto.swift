//
//  LostArticleDetailDto.swift
//  koin
//
//  Created by 김나훈 on 1/15/25.
//

import Foundation

struct LostArticleDetailDto: Decodable {
    let id, boardId: Int
    let type: LostItemType?
    let category, foundPlace, foundDate: String
    let content: String
    let author: String?
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
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        id = try container.decode(Int.self, forKey: .id)
        boardId = try container.decode(Int.self, forKey: .boardId)
        type = try container.decodeIfPresent(LostItemType.self, forKey: .type)
        category = try container.decode(String.self, forKey: .category)
        foundPlace = try container.decode(String.self, forKey: .foundPlace)
        foundDate = try container.decode(String.self, forKey: .foundDate)
        content = try container.decodeIfPresent(String.self, forKey: .content) ?? ""
        author = try container.decodeIfPresent(String.self, forKey: .author)
        images = try container.decodeIfPresent([Image].self, forKey: .images)
        isCouncil = try container.decodeIfPresent(Bool.self, forKey: .isCouncil)
        isMine = try container.decodeIfPresent(Bool.self, forKey: .isMine)
        prevId = try container.decodeIfPresent(Int.self, forKey: .prevId)
        nextId = try container.decodeIfPresent(Int.self, forKey: .nextId)
        registeredAt = try container.decode(String.self, forKey: .registeredAt)
        updatedAt = try container.decode(String.self, forKey: .updatedAt)
    }
}

struct Image: Decodable {
    let id: Int?
    let imageUrl: String

    enum CodingKeys: String, CodingKey {
        case id
        case imageUrl = "image_url"
    }
}
