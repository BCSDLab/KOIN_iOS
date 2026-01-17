//
//  LostItemArticle.swift
//  koin
//
//  Created by 홍기정 on 1/18/26.
//

import Foundation

struct LostItemArticle {
    let id: Int
    let type: LostItemType
    let category: String
    let foundPlace: String
    let foundDate: String
    let content: String?
    let author: String
    let registeredAt: String
    let isReported: Bool
    let isFound: Bool
}
