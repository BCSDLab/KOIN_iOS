//
//  CallVanReportRequest.swift
//  koin
//
//  Created by 홍기정 on 3/10/26.
//

import Foundation

struct CallVanReportRequest: Encodable {
    let reportedUserId: Int
    let reasons: [CallVanReportRequestReason]

    enum CodingKeys: String, CodingKey {
        case reportedUserId = "reported_user_id"
        case reasons
    }
}

// MARK: - Reason
struct CallVanReportRequestReason: Encodable {
    var reasonCode: CallVanReportRequestReasonCode? = nil
    var customReason: String? = nil

    enum CodingKeys: String, CodingKey {
        case reasonCode = "reason_code"
        case customReason = "custom_text"
    }
}

enum CallVanReportRequestReasonCode: String, Encodable {
    case noShow = "NO_SHOW"
    case nonPayment = "NON_PAYMENT"
    case profanity = "PROFANITY"
    case other = "OTHER"
    
    var title: String {
        switch self {
        case .noShow: 
            return "노쇼"
        case .nonPayment:
            return "비용 미납"
        case .profanity:
            return "욕설"
        case .other:
            return "기타"
        }
    }
    
    var description: String? {
        switch self {
        case .noShow: 
            return "참여 신청 후 약속 장소에 나타나지 않았습니다."
        case .nonPayment:
            return "콜밴 비용을 납부하지 않았습니다."
        case .profanity:
            return "욕설, 성적인 언어, 비방하는 언어를 사용했습니다."
        case .other:
            return nil
        }
    }
    
    init?(title: String) {
        switch title {
        case "노쇼":
            self = .noShow
        case "비용 미납":
            self = .nonPayment
        case "욕설":
            self = .profanity
        case "기타":
            self = .other
        default:
            return nil
        }
        
    }
}
