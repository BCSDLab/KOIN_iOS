//
//  WriteReviewRequest.swift
//  koin
//
//  Created by 김나훈 on 8/11/24.
//

import Foundation

struct WriteReviewRequest: Encodable {
    let raiting: Int
    let content: String
    let imageUrls: [String]
    let menuNames: [String]
    
    enum CodingKeys: String, CodingKey {
        case raiting 
        case content
        case imageUrls = "image_urls"
        case menuNames = "menu_names"
    }
}
