//
//  LandListFilter.swift
//  koin
//
//  Created by 홍기정 on 11/23/26.
//

import Foundation

enum LandListFilter: CaseIterable {
    case all
    case monthly
    case charter
    
    var displayName: String {
        switch self {
        case .all: "전체"
        case .monthly: "월세"
        case .charter: "전세"
        }
    }
}
