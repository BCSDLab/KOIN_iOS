//
//  RecruitMeetingType.swift
//  koin
//
//  Created by 홍기정 on 8/29/26.
//

import Foundation

enum RecruitMeetingType: String, CaseIterable {
    case online = "온라인"
    case offline = "오프라인"
    case mixed = "온 · 오프라인"
    
    var index: Int {
        switch self {
        case .online:
            1
        case .offline:
            2
        case .mixed:
            3
        }
    }
    
    var imageAsset: ImageAsset {
        switch self {
        case .online:
            return .recruitPostMeetingTypeOnline
        case .offline:
            return .recruitPostMeetingTypeOffline
        case .mixed:
            return .recruitPostMeetingTypeMixed
        }
    }
}

extension RecruitMeetingType {
    init?(index: Int) {
        switch index {
        case 1:
            self = .online
        case 2:
            self = .offline
        case 3:
            self = .mixed
        default:
            return nil
        }
    }
}
