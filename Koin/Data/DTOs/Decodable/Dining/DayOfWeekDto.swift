enum DayOfWeekDto: String, Decodable {
    case weekday = "평일"
    case weekend = "주말"
}

extension DayOfWeekDto {
    func toDomain() -> DayOfWeek {
        switch self {
        case .weekday: .weekday
        case .weekend: .weekend
        }
    }
}
