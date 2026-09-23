//
//  RecruitMyApplicationStatus.swift
//  koin
//
//  Created by 홍기정 on 9/24/26.
//

import Foundation

enum RecruitMyApplicationStatus: String, CaseIterable, Equatable {
    case accepted = "승인"
    case denied = "거절"
    case pending = "대기"

    var textColor: ColorAsset {
        switch self {
        case .accepted:
            return .new600
        case .denied:
            return .danger700
        case .pending:
            return .neutral500
        }
    }
}
