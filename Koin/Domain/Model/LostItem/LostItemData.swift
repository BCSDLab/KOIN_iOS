//
//  LostItemData.swift
//  koin
//
//  Created by 홍기정 on 1/19/26.
//

import Foundation

// MARK: - LostItemData
struct LostItemData {
    let id, boardID: Int
    let type, category, foundPlace, foundDate: String
    let content, author: String
    let isCouncil, isMine, isFound: Bool
    let images: [Image]
    let prevID, nextID: Int
    let registeredAt, updatedAt: String
}
