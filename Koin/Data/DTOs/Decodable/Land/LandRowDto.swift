//
//  LandRowDto.swift
//  koin
//
//  Created by 홍기정 on 11/23/26.
//

import Foundation

struct LandRowDto: Decodable {
    let id: Int
    let name: String
    let address: String?
    let roomType: String?
    let latitude: Double?
    let longitude: Double?
    let isMonthlyAvailable: Bool
    let isCharterAvailable: Bool

    enum CodingKeys: String, CodingKey {
        case id, name
        case address
        case roomType = "room_type"
        case latitude, longitude
        case isMonthlyAvailable = "is_monthly_available"
        case isCharterAvailable = "is_charter_available"
    }
}

extension LandRowDto {
    func toDomain() -> LandRow {
        LandRow(
            id: id,
            name: name,
            isMonthlyAvailable: isMonthlyAvailable,
            isCharterAvailable: isCharterAvailable,
            roomType: roomType,
            address: address,
            coordinate: LandCoordinate(
                latitude: latitude,
                longitude: longitude
            )
        )
    }
}

