//
//  CallVanRecruitmentState.swift
//  koin
//
//  Created by 홍기정 on 3/15/26.
//

import Foundation

enum CallVanRecruitmentState: String, CallVanFilterState {
    case all = "전체"
    case recruiting = "모집중"
    case closed = "모집마감"
    
    var index: Int {
        switch self {
        case .all: 0
        case .recruiting: 1
        case .closed: 2
        }
    }
}
