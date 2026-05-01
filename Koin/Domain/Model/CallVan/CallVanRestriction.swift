//
//  CallVanRestriction.swift
//  koin
//
//  Created by 홍기정 on 4/8/26.
//

import Foundation

struct CallVanRestriction {
    let isRestricted: Bool
    let restrictionType: RestrictionType?
    let restrictedUntil: String?
}

enum RestrictionType: String {
    case temporaryRestriction14Days = "14일 이용 정지"
    case permanentRestriction = "영구 정지"
    
    func getDescription(until: String? = nil) -> String {
        switch self {
        case .temporaryRestriction14Days:
            return "해당 계정은 \(until ?? "")까지\n콜밴팟 기능을 사용할 수 없습니다."
        case .permanentRestriction:
            return "해당 계정은 콜밴팟 기능을\n사용할 수 없습니다."
        }
    }
}
