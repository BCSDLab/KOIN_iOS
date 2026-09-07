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
}
