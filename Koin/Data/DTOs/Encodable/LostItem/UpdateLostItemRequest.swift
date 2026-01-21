//
//  UpdateLostItemRequest.swift
//  koin
//
//  Created by 홍기정 on 1/21/26.
//

import Foundation

struct UpdateLostItemRequest {
    let category: String
    let foundPlace: String
    let foundDate: String
    let content: String?
    let newImages: [String]
    let deleteImageIds: [Int]
}
