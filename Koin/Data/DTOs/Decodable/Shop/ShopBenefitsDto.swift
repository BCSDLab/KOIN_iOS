//
//  ShopBenefits.swift
//  koin
//
//  Created by 김나훈 on 9/23/24.
//

import Foundation

struct ShopBenefitsDto: Decodable {
    let benefits: [Benefit]?
}

struct Benefit: Decodable {
    let id: Int
    let title, detail: String
    let onImageURL, offImageURL: String
    
    enum CodingKeys: String, CodingKey {
        case id, title, detail
        case onImageURL = "on_image_url"
        case offImageURL = "off_image_url"
    }
}
