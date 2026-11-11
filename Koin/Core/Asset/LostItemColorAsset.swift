//
//  LostItemColorAsset.swift
//  Koin
//

import Foundation

public enum LostItemColorAsset: String {
    case electronics = "전자제품"
    case card = "카드"
    case wallet = "지갑"
    case id = "신분증"
    case etc = "기타"
    case unknown

    var foreground: ColorAsset {
        switch self {
        case .electronics: return .info700
        case .card: return .success700
        case .wallet: return .new600
        case .id: return .warning600
        case .etc: return .danger600
        case .unknown: return .neutral500
        }
    }

    var background: ColorAsset {
        switch self {
        case .electronics: return .info200
        case .card: return .success200
        case .wallet: return .new100
        case .id: return .warning100
        case .etc: return .danger200
        case .unknown: return .neutral100
        }
    }
}
