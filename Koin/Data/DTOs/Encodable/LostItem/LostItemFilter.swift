//
//  LostItemFilter.swift
//  koin
//
//  Created by 홍기정 on 1/17/26.
//

import Foundation

struct FetchLostItemRequest: Encodable {
    var type: LostItemType? = nil
    var page: Int = 1
    let limit: Int = 10
    var category: LostItemCategory = .all
    var foundStatus: LostItemFoundStatus = .all
    let sort: LostItemSort = .latest
    var author: LostItemAuthor = .all
    var title: String? = nil
}

enum LostItemCategory: String, Encodable {
    case all = "ALL"
    case card = "CARD"
    case id = "ID"
    case wallet = "WALLET"
    case electronics = "ELECTRONICS"
    case etc = "ETC"
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
