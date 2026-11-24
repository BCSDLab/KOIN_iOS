//
//  LandListDto.swift
//  koin
//
//  Created by 홍기정 on 11/23/26.
//

import Foundation

struct LandListDto: Decodable {
    let lands: [LandRowDto]
}

extension LandListDto {
    func toDomain() -> LandList {
        LandList(rows: lands.map { $0.toDomain() })
    }
}

