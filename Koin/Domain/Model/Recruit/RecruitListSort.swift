//
//  RecruitListSort.swift
//  koin
//
//  Created by 홍기정 on 8/29/26.
//

import Foundation

enum RecruitListSort: String {
    case latestDescending = "최신순"
    case deadlineAscending = "마감임박순"
    
    var index: Int {
        switch self {
        case .latestDescending:
            0
        case .deadlineAscending:
            1
        }
    }
}
