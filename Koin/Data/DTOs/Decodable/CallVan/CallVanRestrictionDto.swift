//
//  CallVanRestrictionDto.swift
//  koin
//
//  Created by 홍기정 on 4/8/26.
//

import Foundation

struct CallVanRestrictionDto: Decodable {
    let isRestricted: Bool
    let restrictionType: RestrictionTypeDto?
    let restrictedUntil: String?

    enum CodingKeys: String, CodingKey {
        case isRestricted = "is_restricted"
        case restrictionType = "restriction_type"
        case restrictedUntil = "restricted_until"
    }
}

enum RestrictionTypeDto: String, Decodable {
    case temporaryRestriction14Days = "TEMPORARY_RESTRICTION_14_DAYS"
    case premanentRestriction = "PERMANENT_RESTRICTION"
}

extension CallVanRestrictionDto {
    func toDomain() -> CallVanRestriction {
        let formattedRestrictedUntil: String?
        if let restrictedUntil {
            formattedRestrictedUntil = formatter(restrictedUntil: restrictedUntil)
        } else {
            formattedRestrictedUntil = nil
        }
        
        return CallVanRestriction(
            isRestricted: isRestricted,
            restrictionType: restrictionType?.toDomain(),
            restrictedUntil: formattedRestrictedUntil
        )
    }
    
    private func formatter(restrictedUntil: String) -> String {
        let inputFormatter = DateFormatter()
        inputFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSZ"
        let outputFormatter = DateFormatter()
        outputFormatter.dateFormat = "M월 d일"
        
        if let date = inputFormatter.date(from: restrictedUntil) {
            return outputFormatter.string(from: date)
        } else {
            return ""
        }
    }
}

extension RestrictionTypeDto {
    func toDomain() -> RestrictionType {
        switch self {
        case .temporaryRestriction14Days: .temporaryRestriction14Days
        case .premanentRestriction: .premanentRestriction
        }
    }
}
