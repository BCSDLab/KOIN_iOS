//
//  LandMapView.swift
//  koin
//
//  Created by 홍기정 on 11/22/26.
//

import UIKit
import NMapsMap
import Combine
import SnapKit

final class LandMapView: UIView {
    typealias ItemKey = LandMarkerKey
    
    private static let initialCoordinate = LandCoordinate(latitude: 36.766205, longitude: 127.284638)
    
    // MARK: - Properties
    var markerTappedPublisher: AnyPublisher<ItemKey, Never> {
        leafMarkerUpdater.markerTappedPublisher.eraseToAnyPublisher()
    }
    var clusterTappedPublisher: AnyPublisher<Void, Never> {
        clusterMarkerUpdater.clusterTappedPublisher.eraseToAnyPublisher()
    }
    
    // MARK: - Cluster
    private let leafMarkerUpdater = LandMapViewLeafMarkerUpdater()
    private let clusterMarkerUpdater = LandMapViewClusterMarkerUpdater()
    private lazy var builder = NMCBuilder<ItemKey>().then {
        $0.leafMarkerUpdater = leafMarkerUpdater
        $0.clusterMarkerUpdater = clusterMarkerUpdater
    }
    private lazy var clusterer = builder.build().then {
        $0.mapView = mapView
    }

    // MARK: - UI Components
    private let mapView = NMFMapView().then {
        $0.mapType = .basic
        $0.minZoomLevel = 12
    }
    
    // MARK: - Initializer
    init() {
        super.init(frame: .zero)
        configureView()
        focus(on: Self.initialCoordinate, animationDuration: 0)
    }
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

extension LandMapView {
    func configure(_ markerKeys: [ItemKey]) {
        let keyTagMap = markerKeys.reduce(into: [ItemKey: NSNull]()) { result, markerKey in
            result[markerKey] = NSNull()
        }
        clusterer.clear()
        clusterer.addAll(keyTagMap)
    }
    
    func configure(_ markerKey: ItemKey) {
        configure([markerKey])
    }
}

extension LandMapView {
    /// safeAreaInsets.bottom 을 제외한 바텀시트 콘텐츠 높이만큼 contentInset.bottom 을 적용한다
    func setContentInset(bottom: CGFloat) {
        mapView.contentInset = UIEdgeInsets(
            top: 0,
            left: 0,
            bottom: bottom,
            right: 0
        )
    }
}

extension LandMapView {
    func focus(
        on coordinate: LandCoordinate,
        animationDuration: TimeInterval = 0.2
    ) {
        let cameraUpdate = NMFCameraUpdate(
            scrollTo: NMGLatLng(
                lat: coordinate.latitude,
                lng: coordinate.longitude
            )
        )
        cameraUpdate.animation = .easeOut
        cameraUpdate.animationDuration = animationDuration
        mapView.moveCamera(cameraUpdate)
    }
}

extension LandMapView {
    func zoomIn() {
        let cameraUpdate = NMFCameraUpdate.withZoomIn()
        cameraUpdate.animation = .easeOut
        mapView.moveCamera(cameraUpdate)
    }
    
    func zoomOut() {
        let cameraUpdate = NMFCameraUpdate.withZoomOut()
        cameraUpdate.animation = .easeOut
        mapView.moveCamera(cameraUpdate)
    }
}

extension LandMapView {
    private func configureView() {
        addSubview(mapView)
        mapView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
    }
}
