//
//  OrderImage.swift
//  koin
//
//  Created by 홍기정 on 9/13/25.
//

import Foundation

struct OrderImage {
    let imageUrl: String?
    let isThumbnail: Bool
}

extension OrderImage {    
    init(from dto: OrderImageDto) {
        self.imageUrl = dto.imageUrl
        self.isThumbnail = dto.isThumbnail
    }
}
