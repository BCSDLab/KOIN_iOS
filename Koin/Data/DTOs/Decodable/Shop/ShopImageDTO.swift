//
//  ShopImageDTO.swift
//  koin
//
//  Created by 홍기정 on 9/14/25.
//

import Foundation

// MARK: - Image
struct ShopImageDTO: Decodable {
    let imageUrl: String
    let isThumbnail: Bool

    enum CodingKeys: String, CodingKey {
        case imageUrl = "image_url"
        case isThumbnail = "is_thumbnail"
    }
}
