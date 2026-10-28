//
//  DiningPlace.swift
//  Koin
//
//  Created by 김나훈 on 3/9/24.
//  Nullable 2024.04.26

enum DiningPlace: Equatable, CaseIterable {
    case cornerA
    case cornerB
    case cornerC
    case special
    case secondCampus

    var name: String {
        switch self {
        case .cornerA: "A코너"
        case .cornerB: "B코너"
        case .cornerC: "C코너"
        case .special: "능수관"
        case .secondCampus: "2캠퍼스"
        }
    }

    var order: Int {
        switch self {
        case .cornerA: 0
        case .cornerB: 1
        case .cornerC: 2
        case .special: 3
        case .secondCampus: 4
        }
    }
}
