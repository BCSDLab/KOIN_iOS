//
//  ClubCategoriesDto.swift
//  koin
//
//  Created by 김나훈 on 6/13/25.
//

struct ClubCategoriesDto: Decodable {
    let clubCategories: [ClubCategory]

    enum CodingKeys: String, CodingKey {
        case clubCategories = "club_categories"
    }
}

// MARK: - ClubCategory
struct ClubCategory: Codable {
    let id: Int
    let name: String
}
