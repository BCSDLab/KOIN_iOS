//
//  LandDetailDto.swift
//  koin
//
//  Created by 김나훈 on 3/17/24.
//

import Foundation

struct LandDetailDto: Decodable {
    let id: Int
    let name: String
    let latitude: Double?
    let longitude: Double?
    let imageUrls: [String]?
    let monthlyFee: String?
    let charterFee: String?
    let deposit: String?
    let managementFee: String?
    let size: String
    let roomType: String
    let phone: String

    enum CodingKeys: String, CodingKey {
        case id, name, latitude, longitude
        case imageUrls = "image_urls"
        case monthlyFee = "monthly_fee"
        case charterFee = "charter_fee"
        case deposit
        case managementFee = "management_fee"
        case size
        case roomType = "room_type"
        case phone
    }
}

extension LandDetailDto {
    func toDomain() -> LandDetail {
        return LandDetail(
            id: id,
            name: name,
            coordinate: LandCoordinate(
                latitude: latitude,
                longitude: longitude
            ),
            imageUrls: imageUrls ?? [],
            monthlyFee: monthlyFee,
            charterFee: charterFee,
            deposit: deposit,
            managementFee: managementFee,
            size: size,
            roomType: roomType,
            phone: phone
        )
    }
}
