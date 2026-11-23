//
//  LandMapView+OverlayImage.swift
//  koin
//
//  Created by 홍기정 on 11/22/26.
//

import NMapsMap

extension NMFOverlayImage {
    static let LandMarker = NMFOverlayImage(
        image: UIImage.appImage(asset: .landMarker) ?? UIImage(),
        reuseIdentifier: ImageAsset.landMarker.rawValue
    )
    static let LandCluster2to3 = NMFOverlayImage(
        image: UIImage.appImage(asset: .landCluster2to3) ?? UIImage(),
        reuseIdentifier: ImageAsset.landCluster2to3.rawValue
    )
    static let LandCluster4to6 = NMFOverlayImage(
        image: UIImage.appImage(asset: .landCluster4to6) ?? UIImage(),
        reuseIdentifier: ImageAsset.landCluster4to6.rawValue
    )
    static let LandCluster7to9 = NMFOverlayImage(
        image: UIImage.appImage(asset: .landCluster7to9) ?? UIImage(),
        reuseIdentifier: ImageAsset.landCluster7to9.rawValue
    )
    static let LandCluster10to12 = NMFOverlayImage(
        image: UIImage.appImage(asset: .landCluster10to12) ?? UIImage(),
        reuseIdentifier: ImageAsset.landCluster10to12.rawValue
    )
}
