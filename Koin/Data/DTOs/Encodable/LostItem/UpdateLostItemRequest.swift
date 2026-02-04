//
//  UpdateLostItemRequest.swift
//  koin
//
//  Created by 홍기정 on 1/21/26.
//

import Foundation

struct UpdateLostItemRequest: Encodable {
    let category: String
    let foundPlace: String
    let foundDate: String
    let content: String?
    let newImages: [String]
    let deleteImageIds: [Int]
    
    enum CodingKeys: String, CodingKey {
        case category
        case foundPlace = "found_place"
        case foundDate = "found_date"
        case content
        case newImages = "new_images"
        case deleteImageIds = "delete_image_ids"
    }
}
