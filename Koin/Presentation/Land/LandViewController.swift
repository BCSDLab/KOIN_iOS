//
//  LandViewContoller.swift
//  Koin
//
//  Created by 김나훈 on 3/14/24.
//

import Combine
import NMapsMap
import UIKit

final class LandViewController: UIViewController {
    // MARK: - Properties
    
    private let viewModel: LandViewModel
    private let inputSubject: PassthroughSubject<LandViewModel.Input, Never> = .init()
    private var subscriptions: Set<AnyCancellable> = []
    
    // MARK: - UI Components
    
    private let mapView: NMFMapView = {
        let map = NMFMapView()
        return map
    }()
    
    private let landCollectionView: LandCollectionView = {
        let flowLayout = UICollectionViewFlowLayout()
        flowLayout.minimumLineSpacing = 20
        flowLayout.scrollDirection = .vertical
        let cellWidth = UIScreen.main.bounds.width / 2 - 20
        flowLayout.itemSize = CGSize(width: cellWidth, height: 110)
        let collectionView = LandCollectionView(frame: .zero, collectionViewLayout: flowLayout)
        return collectionView
    }()
    
    // MARK: - Initialization
    
    init(viewModel: LandViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Life Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationController?.setNavigationBarHidden(false, animated: true)
        bind()
        configureView()
        inputSubject.send(.viewDidLoad)
        
    }
    
    // MARK: - Bind
    
    private func bind() {
        let outputSubject = viewModel.transform(with: inputSubject.eraseToAnyPublisher())
        outputSubject.receive(on: DispatchQueue.main).sink { [weak self] output in
            switch output {
            case let .showLandList(landList):
                self?.showLandList(items: landList)
                self?.putMarkers(items: landList)
            }
        }.store(in: &subscriptions)
        
        landCollectionView.cellTapPublisher
            .sink { [weak self] shopId in
                self?.navigateToLandDetailViewController(id: shopId)
            }
            .store(in: &subscriptions)
    }
}

extension LandViewController {

    private func navigateToLandDetailViewController(id: Int) {
        
        let landService = DefaultLandService()
        let landRepository = DefaultLandRepository(service: landService)
        let fetchLandDetailUseCase = DefaultFetchLandDetailUseCase(landRepository: landRepository)
        let logAnalyticsEventUseCase = DefaultLogAnalyticsEventUseCase(repository: GA4AnalyticsRepository(service: GA4AnalyticsService()))
        let viewModel = LandDetailViewModel(fetchLandDetailUseCase: fetchLandDetailUseCase, logAnalyticsEventUseCase: logAnalyticsEventUseCase, landId: id)
        let landDetailViewController = LandDetailViewController(viewModel: viewModel)
        landDetailViewController.title = "복덕방"
        navigationController?.pushViewController(landDetailViewController, animated: true)
    }
    
    private func showLandList(items: [LandItem]) {
        landCollectionView.setLandList(items)
    }
    
    private func putMarkers(items: [LandItem]) {
        for land in items {
            let marker = NMFMarker()
            marker.position = NMGLatLng(lat: land.latitude, lng: land.longitude)
            marker.width = 25
            marker.height = 35
            marker.userInfo = ["id": land.id]
            marker.mapView = mapView
            
            marker.touchHandler = { [weak self] (overlay: NMFOverlay) -> Bool in
                if let marker = overlay as? NMFMarker, let id = marker.userInfo["id"] as? Int {
                    self?.navigateToLandDetailViewController(id: id)
                }
                return true
            }
        }
        
        let targetPosition = NMGLatLng(lat: 36.766205, lng: 127.284638)
        let cameraUpdate = NMFCameraUpdate(scrollTo: targetPosition)
        mapView.moveCamera(cameraUpdate)
        
    }
    
}

extension LandViewController {
    
    private func setUpLayOuts() {
        [mapView, landCollectionView].forEach {
            view.addSubview($0)
        }
    }
    
    private func setUpConstraints() {
        mapView.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide.snp.top)
            make.leading.trailing.equalToSuperview()
            make.bottom.equalTo(view.snp.centerY)
        }
        landCollectionView.snp.makeConstraints { make in
            make.top.equalTo(view.snp.centerY).offset(10)
            make.leading.equalTo(view.snp.leading).offset(10)
            make.trailing.equalTo(view.snp.trailing).offset(-10)
            make.bottom.equalTo(view.safeAreaLayoutGuide.snp.bottom)
        }
    }
    
    private func configureView() {
        setUpLayOuts()
        setUpConstraints()
        self.view.backgroundColor = .systemBackground
    }
}

