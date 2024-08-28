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

extension NoticeListDTO {
    func toDomain() -> NoticeListDTO {
        var newArticles: [NoticeArticleDTO] = []
        if let articles = articles {
            for article in articles {
                newArticles.append(article.toDomainWithChangedDate())
            }
        }
        return NoticeListDTO(articles: newArticles, totalCount: totalCount, currentCount: currentCount, totalPage: totalPage, currentPage: currentPage)
    }
}

extension NoticeArticleDTO {
    func toDomain() -> NoticeDataInfo {
        let imageString = content?.extractImageStringFromHtmlTag()
        let date = DateFormatter().date(from: createdAt) ?? Date()
        let newDate = date.formatDateToMMDDE()
        return NoticeDataInfo(title: title, boardId: boardId, content: content ?? "", nickName: nickname, hit: hit, createdAt: newDate, updatedAt: updatedAt, imageString: imageString)
    }
    
    func toDomainWithChangedDate() -> NoticeArticleDTO {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        let date = dateFormatter.date(from: createdAt) ?? Date()
        let newDate = date.formatDateToMMDDE()
        return NoticeArticleDTO(id: id, boardId: boardId, title: title, nickname: nickname, hit: hit, content: content, createdAt: newDate, updatedAt: updatedAt)
    }
}
