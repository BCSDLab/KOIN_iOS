//
//  LandMarkerKey.swift
//  koin
//
//  Created by 홍기정 on 11/22/26.
//

import Foundation
import NMapsMap

final class LandMarkerKey: NSObject {
    // MARK: - Properties
    let identifier: Int
    let position: NMGLatLng
    
    // MARK: - Initializer
    convenience init?(
        id identifier: Int,
        coordinate: LandCoordinate?
    ) {
        guard let coordinate else {
            return nil
        }
        self.init(
            id: identifier,
            position: NMGLatLng(
                lat: coordinate.latitude,
                lng: coordinate.longitude
            )
        )
    }
    
    init(
        id identifier: Int,
        position: NMGLatLng
    ) {
        self.identifier = identifier
        self.position = position
    }
}

extension LandMarkerKey: NMCClusteringKey {
    override func isEqual(_ object: Any?) -> Bool {
        guard let object = object as? Self else {
            return false
        }
        if object === self {
            return true
        }
        return object.identifier == self.identifier
    }

    override var hash: Int {
        self.identifier
    }
    
    func copy(with zone: NSZone? = nil) -> Any {
        return Self.init(
            id: identifier,
            position: self.position
        )
    }
}
