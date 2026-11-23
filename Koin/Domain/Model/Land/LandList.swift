//
//  LandList.swift
//  koin
//
//  Created by 홍기정 on 11/22/26.
//

import Foundation

struct LandList {
    static let empty = LandList(rows: [])
    
    let rows: [LandRow]
}

extension LandList {
    /// 전체 매물 중심 좌표를 계산한다.
    /// 매물 목록이 비어있을 경우 nil을 반환한다.
    var medianCoordinate: LandCoordinate? {
        let coordinates = rows.compactMap(\.coordinate)
        guard !coordinates.isEmpty else {
            return nil
        }
        let latitudes = coordinates.map(\.latitude)
        let longitudes = coordinates.map(\.longitude)
        return LandCoordinate(
            latitude: median(latitudes),
            longitude: median(longitudes)
        )
    }
    
    private func median(_ array: [Double]) -> Double {
        let sorted = array.sorted()
        let mid = sorted.count / 2
        if sorted.count % 2 == 1 {
            return sorted[mid]
        } else {
            return (sorted[mid - 1] + sorted[mid]) / 2.0
        }
    }
}
