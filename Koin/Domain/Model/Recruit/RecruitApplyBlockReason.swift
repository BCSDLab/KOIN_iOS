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
    
    var toastMessage: String {
        switch self {
        case .loginRequired:
            return "로그인이 필요한 기능입니다."
        case .profileRequired:
            return "팀원모집 프로필이 필요합니다."
        case .alreadyApplied:
            return "이미 지원한 모집글입니다."
        case .recruitmentDeleted:
            return "삭제된 모집글입니다."
        case .ownRecruitment:
            return "내가 작성한 모집글입니다."
        case .recruitmentClosed:
            return "모집이 마감된 모집글입니다."
        case .deadlinePassed:
            return "마감일이 지난 모집글입니다."
        case .roleClosed:
            return "모집이 마감된 역할입니다."
        }
    }
}
