//
//  LostItemKeyword.swift
//  koin
//
//  Created by 홍기정 on 5/12/26.
//

import Foundation

struct LostItemKeywords {
    let count: Int
    let keywords: [LostItemKeyword]
}

struct LostItemKeyword: Equatable {
    let id: Int?
    let keyword: String
}
