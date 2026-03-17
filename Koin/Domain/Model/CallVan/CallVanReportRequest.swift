//
//  CallVanReportRequest.swift
//  koin
//
//  Created by 홍기정 on 3/15/26.
//

import Foundation

struct CallVanReportRequest {
    let reportedUserId: Int
    var reasons: Set<CallVanReportRequestReason> = []
    var descriptions: String?
    var imageUrls: [String] = []
}

struct CallVanReportRequestReason: Hashable {
    var reasonCode: CallVanReportRequestReasonCode
    var customReason: String?
    
    static func ==(lhs: CallVanReportRequestReason, rhs: CallVanReportRequestReason) -> Bool {
        return lhs.reasonCode == rhs.reasonCode
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(reasonCode)
    }
}

enum CallVanReportRequestReasonCode: String {
    case noShow = "노쇼"
    case nonPayment = "비용 미납"
    case profanity = "욕설"
    case other = "기타"
    
    var description: String {
        switch self {
        case .noShow:
            return "참여 신청 후 약속 장소에 나타나지 않았습니다."
        case .nonPayment:
            return "콜밴 비용을 납부하지 않았습니다."
        case .profanity:
            return "욕설, 성적인 언어, 비방하는 언어를 사용했습니다."
        case .other:
            return ""
        }
    }
}

struct CallVanReportRequestAttachment {
    let attachmentType: CallVanReportRequestAttachmentType
    let url: String?
}

enum CallVanReportRequestAttachmentType {
    case image
}
