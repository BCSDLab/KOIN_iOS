//
//  ReportSoldoutRequestDto.swift
//  koin
//
//  Created by 홍기정 on 10/18/26.
//

import Foundation

struct ReportSoldoutRequestDto: Encodable {
    let imageUrl: String
    
    enum CodingKeys: String, CodingKey {
        case imageUrl = "image_url"
    }
}
