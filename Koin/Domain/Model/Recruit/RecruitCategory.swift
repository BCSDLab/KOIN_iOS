//
//  RecruitCategory.swift
//  koin
//
//  Created by 홍기정 on 8/29/26.
//

import Foundation

enum RecruitCategory: String, CaseIterable {
    case contest = "공모전"
    case externalActivity = "대외활동"
    case study = "스터디"
    case project = "프로젝트"
    case other = "기타"
    
    var backgroundColor: ColorAsset {
        switch self {
        case .contest:
            return .info200
        case .externalActivity:
            return .success200
        case .study:
            return .new100
        case .project:
            return .warning100
        case .other:
            return .warning200
        }
    }
    
    var foregroundColor: ColorAsset {
        switch self {
        case .contest:
            return .info700
        case .externalActivity:
            return .success700
        case .study:
            return .new600
        case .project:
            return .warning600
        case .other:
            return .danger600
        }
    }
    
    var index: Int {
        switch self {
        case .contest:
            1
        case .externalActivity:
            2
        case .study:
            3
        case .project:
            4
        case .other:
            5
        }
    }
}
