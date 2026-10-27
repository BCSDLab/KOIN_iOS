//
//  MealType.swift
//  koin
//
//  Created by 김나훈 on 7/19/24.
//

enum MealType {
    case breakfast
    case lunch
    case dinner

    var name: String {
        switch self {
        case .breakfast: "아침"
        case .lunch: "점심"
        case .dinner: "저녁"
        }
    }
}

extension MealType {
    func toDiningType() -> DiningType {
        switch self {
        case .breakfast:
            return .breakfast
        case .lunch:
            return .lunch
        case .dinner:
            return .dinner
        }
    }
}
