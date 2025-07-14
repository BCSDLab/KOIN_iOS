//
//  HotClubDTO.swift
//  koin
//
//  Created by 김나훈 on 6/13/25.
//

import Foundation

struct HotClubDTO: Codable {
    let clubId: Int
    let name: String
    let imageUrl: String

    enum CodingKeys: String, CodingKey {
        case clubId = "club_id"
        case name
        case imageUrl = "image_url"
    }
}
