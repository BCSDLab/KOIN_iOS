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
    case premanentRestriction = "영구 정지"
    
    func getDescription(until: String?) -> String {
        switch self {
        case .temporaryRestriction14Days:
            return "해당 계정은 \(until ?? "")까지\n콜벤팟 기능을 사용할 수 없습니다."
        case .premanentRestriction:
            return "해당 계정은 콜벤팟 기능을\n사용할 수 없습니다."
        }
    }
}
