//
//  AppImage.swift
//  koin
//
//  Created by 김나훈 on 1/15/25.
//

import Foundation

struct AppImage: Decodable {
    let id: Int?
    let imageUrl: String

    enum CodingKeys: String, CodingKey {
        case id
        case imageUrl = "image_url"
    }
}
