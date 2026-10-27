enum DayOfWeekDto: String, Decodable {
    case weekday = "평일"
    case weekend = "주말" // TODO: 삭제
    case saturday = "토요일"
    case sunday = "일요일"
}

extension DayOfWeekDto {
    func toDomain() -> DayOfWeek {
        switch self {
        case .weekday: .weekday
        case .weekend: .weekend
        case .saturday: .saturday
        case .sunday: .sunday
        }
    }
}
