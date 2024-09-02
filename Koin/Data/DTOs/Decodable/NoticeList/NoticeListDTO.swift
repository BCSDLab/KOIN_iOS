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
    let title, author: String
    let hit: Int
    let content: String?
    let updatedAt: String
    let prevId: Int?
    let nextId: Int?
    let registeredAt: String
    
    enum CodingKeys: String, CodingKey {
        case id
        case boardId = "board_id"
        case title, author, hit, content
        case prevId = "prev_id"
        case nextId = "next_id"
        case updatedAt = "updated_at"
        case registeredAt = "registered_at"
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
        let date = DateFormatter().date(from: registeredAt) ?? Date()
        let newDate = date.formatDateToMMDDE()
        return NoticeDataInfo(title: title, boardId: boardId, content: content ?? "", author: author, hit: hit, prevId: prevId, nextId: nextId, registeredAt: newDate)
    }
    
    func toDomainWithChangedDate() -> NoticeArticleDTO {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        let date = dateFormatter.date(from: registeredAt) ?? Date()
        let newDate = date.formatDateToMMDDE()
        let newTitle = title.replacingOccurrences(of: "\n", with: "")
        return NoticeArticleDTO(id: id, boardId: boardId, title: newTitle, author: author, hit: hit, content: content, updatedAt: updatedAt, prevId: prevId, nextId: nextId, registeredAt: newDate)
    }
}
