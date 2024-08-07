//
//  ShopData.swift
//  koin
//
//  Created by 김나훈 on 6/15/24.
//

import Foundation

struct ShopData {
    let address: String
    let name: String
    let delivery: Bool
    let deliveryPrice: Int
    let description: String
    let imageUrls: [String]
    let open: [Open]
    let payBank, payCard: Bool
    let phone: String
    let updatedAt: String
}
