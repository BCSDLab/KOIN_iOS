//
//  Shop.swift
//  koin
//
//  Created by 김나훈 on 8/14/24.
//

import Foundation

struct Shop {
    let categoryIds: [Int]
    let delivery: Bool
    let id: Int
    let name: String
    let payBank: Bool
    let payCard: Bool
    let isEvent: Bool
    let isOpen: Bool
    let reviewCount: Int
    let averageRate: Double
    let benefitDetails: [String]
}
