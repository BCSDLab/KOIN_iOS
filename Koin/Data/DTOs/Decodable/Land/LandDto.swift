//
//  LandDto.swift
//  koin
//
//  Created by 김나훈 on 3/16/24.
//  Nullable 2024.04.26

import Foundation
struct LandDto: Decodable {
    let lands: [Land]?
}

struct Land: Decodable {
    let internalName: String?
    let monthlyFee: String?
    let latitude: Double?
    let charterFee: String?
    let name: String?
    let id: Int
    let longitude: Double?
    let roomType: String?
    
    enum CodingKeys: String, CodingKey {
        case internalName = "internal_name"
        case monthlyFee = "monthly_fee"
        case latitude
        case charterFee = "charter_fee"
        case name, id, longitude
        case roomType = "room_type"
    }
    
    func toDomain() -> LandItem {
        let monthlyFeeString = monthlyFee ?? "-"
        let charterFeeString: String
        if let fee = charterFee { 
            if fee.isEmpty { charterFeeString = "-" }
            else { charterFeeString = "\(fee) 만원" }
        }
        else { charterFeeString = "-" }

        let nameString = name ?? "-"
        
        return .init(
            monthlyFee: monthlyFeeString,
            charterFee: charterFeeString,
            latitude: latitude ?? 0.0,
            longitude: longitude ?? 0.0,
            landName: nameString,
            id: id
        )
    }
}
