//
//  BannerDto.swift
//  koin
//
//  Created by 김나훈 on 4/1/25.
//

struct BannerDto: Codable {
    let count: Int
    let banners: [Banner]
}

// MARK: - Banner
struct Banner: Codable {
    let id: Int
    let title: String
    let imageURL: String
    let redirectLink, version: String?

    enum CodingKeys: String, CodingKey {
        case id, title
        case imageURL = "image_url"
        case redirectLink = "redirect_link"
        case version
    }
}
