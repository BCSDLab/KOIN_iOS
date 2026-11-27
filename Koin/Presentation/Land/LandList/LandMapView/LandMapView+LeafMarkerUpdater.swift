//
//  LandMapView+LeafMarkerUpdater.swift
//  koin
//
//  Created by 홍기정 on 11/22/26.
//

import NMapsMap
import Combine

final class LandMapViewLeafMarkerUpdater: NMCDefaultLeafMarkerUpdater {
    typealias ItemKey = LandMarkerKey
    
    let markerTappedPublisher = PassthroughSubject<ItemKey, Never>()
    
    override func updateLeafMarker(_ info: NMCLeafMarkerInfo, _ marker: NMFMarker) {
        super.updateLeafMarker(info, marker)
        
        if let key = info.key as? ItemKey {
            marker.iconImage = .LandMarker
            marker.touchHandler = { [weak self] _ in
                self?.markerTappedPublisher.send(key)
                return true
            }
        }
    }
}
