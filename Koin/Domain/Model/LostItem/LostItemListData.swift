//
//  LostItemListData.swift
//  koin
//
//  Created by 홍기정 on 1/18/26.
//

import Foundation

struct LostItemListData {
    let id: Int
    let type: LostItemType
    let category: String
    let foundPlace: String
    let foundDate: String
    let content: String?
    let author: String
    let registeredAt: String
    var isReported: Bool
    var isFound: Bool
}
