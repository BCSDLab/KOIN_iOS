//
//  DiningType.swift
//  Koin
//
//  Created by 김나훈 on 3/9/24.
//  Nullable 2024.04.26

enum DiningType {
    case breakfast
    case lunch
    case dinner

    init?(segmentIndex: Int) {
        switch segmentIndex {
        case 0: self = .breakfast
        case 1: self = .lunch
        case 2: self = .dinner
        default: return nil
        }
    }

    var name: String {
        switch self {
        case .breakfast : "아침"
        case .lunch : "점심"
        case .dinner : "저녁"
        }
    }
}
