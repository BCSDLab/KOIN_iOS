//
//  RecruitState.swift
//  koin
//
//  Created by 홍기정 on 8/29/26.
//

import Foundation

enum RecruitState: String {
    case all = "전체"
    case recruiting = "모집중"
    case closed = "모집완료"
    
    var index: Int {
        switch self {
        case .all:
            0
        case .recruiting:
            1
        case .closed:
            2
        }
    }
}
