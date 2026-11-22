//
//  LandCoordinate.swift
//  koin
//
//  Created by 홍기정 on 11/22/26.
//

import Foundation

struct LandCoordinate: Equatable {
    let latitude: Double
    let longitude: Double
}

extension LandCoordinate {
    init?(
        latitude: Double?,
        longitude: Double?
    ) {
        if let latitude, let longitude {
            self.latitude = latitude
            self.longitude = longitude
        } else {
            return nil
        }
    }
}
