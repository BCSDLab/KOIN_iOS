enum MealTypeDto: String, Decodable {
    case breakfast = "아침"
    case lunch = "점심"
    case dinner = "저녁"
}

extension MealTypeDto {
    func toDomain() -> MealType {
        switch self {
        case .breakfast: .breakfast
        case .lunch: .lunch
        case .dinner: .dinner
        }
    }
}
