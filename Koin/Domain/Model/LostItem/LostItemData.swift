//
//  LostItemData.swift
//  koin
//
//  Created by 홍기정 on 1/19/26.
//

import Foundation

// MARK: - LostItemData
struct LostItemData {
    let id: Int
    let boardID: Int
    let type: LostItemType
    let category: String
    let foundPlace: String
    let foundDate: String
    let content: String?
    let author: String
    let isCouncil: Bool
    let isMine: Bool
    let isFound: Bool
    let images: [Image]
    let registeredAt: String
    let updatedAt: String
}
