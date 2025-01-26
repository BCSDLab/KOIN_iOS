//
//  PostLostArticleResponse.swift
//  koin
//
//  Created by 김나훈 on 1/15/25.
//

// MARK: - Article

struct PostLostArticleRequestWrapper: Encodable {
    let articles: [PostLostArticleRequest]
}

struct PostLostArticleRequest: Codable {
    var category, location, foundDate: String
    var content: String?
    var images: [String]?
    let registeredAt, updatedAt: String

    enum CodingKeys: String, CodingKey {
        case category
        case location = "found_place"
        case foundDate = "found_date"
        case content, images
        case registeredAt = "registered_at"
        case updatedAt = "updated_at"
    }
}
