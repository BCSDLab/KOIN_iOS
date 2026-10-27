enum DiningPlaceDto: String, Decodable {
    case cornerA = "A코너"
    case cornerB = "B코너"
    case cornerC = "C코너"
    case special = "능수관"
    case secondCampus = "2캠퍼스"
}

extension DiningPlaceDto {
    init(from model: DiningPlace) {
        switch model {
        case .cornerA: self = .cornerA
        case .cornerB: self = .cornerB
        case .cornerC: self = .cornerC
        case .special: self = .special
        case .secondCampus: self = .secondCampus
        }
    }

    func toDomain() -> DiningPlace {
        switch self {
        case .cornerA: .cornerA
        case .cornerB: .cornerB
        case .cornerC: .cornerC
        case .special: .special
        case .secondCampus: .secondCampus
        }
    }
}
