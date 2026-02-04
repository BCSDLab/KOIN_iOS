//
//  FetchLostItemListRequest.swift
//  koin
//
//  Created by 홍기정 on 1/17/26.
//

import Foundation

struct FetchLostItemListRequest: Encodable {
    var type: LostItemType? = nil
    var page: Int = 1
    var limit: Int = 10
    var category: Set<LostItemCategory> = [.all]
    var foundStatus: LostItemFoundStatus = .all
    let sort: LostItemSort = .latest
    var author: LostItemAuthor = .all
    var title: String? = nil
    
    static func !=(lhs: FetchLostItemListRequest, rhs: FetchLostItemListRequest) -> Bool {
        return lhs.type != rhs.type
        || lhs.category != rhs.category
        || lhs.foundStatus != rhs.foundStatus
        || lhs.author != rhs.author
    }
}

enum LostItemCategory: String, Encodable {
    case all = "ALL"
    case card = "CARD"
    case id = "ID"
    case wallet = "WALLET"
    case electronics = "ELECTRONICS"
    case etc = "ETC"
    
    var description: String {
        switch self {
        case .all: return "전체"
        case .card: return "카드"
        case .wallet: return "지갑"
        case .id: return "신분증"
        case .electronics: return "전자제품"
        case .etc: return "기타"
        }
    }
    
    init?(description: String) {
        switch description {
        case "전체": self = .all
        case "카드": self = .card
        case "지갑": self = .wallet
        case "신분증": self = .id
        case "전자제품": self = .electronics
        case "기타": self = .etc
        default: return nil
        }
    }
}

enum LostItemFoundStatus: String, Encodable {
    case all = "ALL"
    case found = "FOUND"
    case notFound = "NOT_FOUND"
}

enum LostItemSort: String, Encodable {
    case latest = "LATEST"
    case oldest = "OLDEST"
}

enum LostItemAuthor: String, Encodable {
    case all = "ALL"
    case my = "MY"
}
