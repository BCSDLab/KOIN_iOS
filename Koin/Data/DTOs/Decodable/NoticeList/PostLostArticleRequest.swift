//
//  PostLostArticleResponse.swift
//  koin
//
//  Created by 김나훈 on 1/15/25.
//

// MARK: - Article

struct PostLostArticleRequest: Codable {
    let category, location, foundDate: String
    let content: String?
    var images: [String]?
    let registeredAt, updatedAt: String

    enum CodingKeys: String, CodingKey {
        case category, location
        case foundDate = "found_date"
        case content, images
        case registeredAt = "registered_at"
        case updatedAt = "updated_at"
    }
}
