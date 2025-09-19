//
//  LostArticleDto.swift
//  koin
//
//  Created by 김나훈 on 1/15/25.
//

import Foundation

struct LostArticleDto: Codable {
    let articles: [Article]?
    let totalCount, currentCount, totalPage, currentPage: Int

    enum CodingKeys: String, CodingKey {
        case articles
        case totalCount = "total_count"
        case currentCount = "current_count"
        case totalPage = "total_page"
        case currentPage = "current_page"
    }
}

// MARK: - Article
struct Article: Codable {
    let id, boardId: Int
    let category, foundPlace, foundDate: String
    let content: String?
    let author, registeredAt: String

    enum CodingKeys: String, CodingKey {
        case id
        case boardId = "board_id"
        case category
        case foundPlace = "found_place"
        case foundDate = "found_date"
        case content, author
        case registeredAt = "registered_at"
    }
}
