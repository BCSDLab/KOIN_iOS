enum DiningTypeDto: String, Decodable {
    case breakfast = "BREAKFAST"
    case lunch = "LUNCH"
    case dinner = "DINNER"
}

extension DiningTypeDto {
    init(from model: DiningType) {
        switch model {
        case .breakfast: self = .breakfast
        case .lunch: self = .lunch
        case .dinner: self = .dinner
        }
    }

    func toDomain() -> DiningType {
        switch self {
        case .breakfast: .breakfast
        case .lunch: .lunch
        case .dinner: .dinner
        }
    }
}
