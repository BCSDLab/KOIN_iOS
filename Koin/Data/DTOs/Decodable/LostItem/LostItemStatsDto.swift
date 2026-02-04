//
//  LostItemStatsDto.swift
//  koin
//
//  Created by 홍기정 on 1/24/26.
//

import Foundation

struct LostItemStatsDto: Decodable {
    let foundCount: Int
    let notFoundCount: Int
    
    enum CodingKeys: String, CodingKey {
        case foundCount = "found_count"
        case notFoundCount = "not_found_count"
    }
}

extension LostItemStatsDto {
    
    func toDomain() -> LostItemStats {
        return LostItemStats(
            foundCount: self.foundCount,
            notFoundCount: self.notFoundCount
        )
    }
}
