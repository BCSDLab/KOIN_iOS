//
//  LandRow.swift
//  koin
//
//  Created by 홍기정 on 11/22/26.
//

import Foundation

struct LandRow: Equatable {
    let id: Int
    let name: String
    let isMonthlyAvailable: Bool
    let isCharterAvailable: Bool
    
    let roomType: String?
    let address: String?
    let coordinate: LandCoordinate?
}

