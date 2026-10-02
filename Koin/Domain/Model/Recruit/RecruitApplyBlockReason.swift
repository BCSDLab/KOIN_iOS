//
//  RecruitApplyBlockReason.swift
//  koin
//
//  Created by 홍기정 on 10/2/26.
//

import Foundation

enum RecruitApplyBlockReason {
    case recruitmentDeleted
    case loginRequired
    case ownRecruitment
    case alreadyApplied
    case recruitmentClosed
    case deadlinePassed
    case roleClosed
    case profileRequired
}

extension RecruitApplyBlockReason {
    var buttonText: String {
        switch self {
        case .loginRequired, .profileRequired:
            return "지원하기"
        case .alreadyApplied:
            return "지원완료"
        case .recruitmentDeleted, .ownRecruitment, .recruitmentClosed, .deadlinePassed, .roleClosed:
            return "모집완료"
        }
    }
}
