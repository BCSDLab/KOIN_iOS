//
//  LandMapView+ClusterMarkerUpdater.swift
//  koin
//
//  Created by 홍기정 on 11/22/26.
//

import NMapsMap

final class LandMapViewClusterMarkerUpdater: NMCDefaultClusterMarkerUpdater {
    typealias ItemKey = LandMarkerKey
    
    override func updateClusterMarker(_ info: NMCClusterMarkerInfo, _ marker: NMFMarker) {
        super.updateClusterMarker(info, marker)
        
        marker.captionText = ""

        switch info.size {
        case 1:
            marker.iconImage = .LandMarker
        case 2...3:
            marker.iconImage = .LandCluster2to3
        case 4...6:
            marker.iconImage = .LandCluster4to6
        case 7...9:
            marker.iconImage = .LandCluster7to9
        case 10...12:
            marker.iconImage = .LandCluster10to12
        default:
            marker.iconImage = .LandCluster10to12 // FIXME: 디자인 추가 필요
        }
    }
}

