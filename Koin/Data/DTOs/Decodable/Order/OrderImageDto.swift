//
//  OrderImageDto.swift
//  koin
//
//  Created by 홍기정 on 9/14/25.
//

import Foundation

struct OrderImageDto: Codable {
    let imageUrl: String
    let isThumbnail: Bool

    enum CodingKeys: String, CodingKey {
        case imageUrl = "image_url"
        case isThumbnail = "is_thumbnail"
    }
}
