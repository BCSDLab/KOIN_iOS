//
//  PostLostItemResponse.swift
//  koin
//
//  Created by 김나훈 on 1/15/25.
//

// MARK: - Article

struct PostLostItemRequestWrapper: Encodable {
    let articles: [PostLostItemRequest]
}

enum LostItemType: String, Codable, CustomStringConvertible {
    case lost = "LOST"
    case found = "FOUND"
    init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        let rawValue = try container.decode(String.self)
        self = LostItemType(rawValue: rawValue) ?? .lost
    }
    var description: String {
        switch self {
        case .lost: return "분실"
        case .found: return "습득"
        }
    }
    
}

struct PostLostItemRequest: Codable {
    var type: LostItemType?
    var category, location, foundDate: String
    var content: String?
    var images: [String]?
    let registeredAt, updatedAt: String

    enum CodingKeys: String, CodingKey {
        case type = "type"
        case category
        case location = "found_place"
        case foundDate = "found_date"
        case content, images
        case registeredAt = "registered_at"
        case updatedAt = "updated_at"
    }
}
