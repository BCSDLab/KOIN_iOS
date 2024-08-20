//
//  NoticeListDTO.swift
//  koin
//
//  Created by JOOMINKYUNG on 8/13/24.
//

import Foundation

struct NoticeListDTO: Decodable {
    let articles: [NoticeArticleDTO]?
    let totalCount, currentCount, totalPage, currentPage: Int
    
    enum CodingKeys: String, CodingKey {
        case articles
        case totalCount = "total_count"
        case currentCount = "current_count"
        case totalPage = "total_page"
        case currentPage = "current_page"
    }
}

struct NoticeArticleDTO: Decodable {
    let id, boardId: Int
    let title, nickname: String
    let hit: Int
    let content: String?
    let createdAt, updatedAt: String
    
    enum CodingKeys: String, CodingKey {
        case id
        case boardId = "board_id"
        case title, nickname, hit, content
        case createdAt = "created_at"
        case updatedAt = "updated_at"
    }
}

extension NoticeArticleDTO {
    func toDomain() -> NoticeDataInfo {
        let imageString = content?.extractImageStringFromHtmlTag()
        return NoticeDataInfo(title: title, boardId: boardId, content: content ?? "", nickName: nickname, hit: hit, createdAt: createdAt, updatedAt: updatedAt, imageString: imageString)
    }
}
