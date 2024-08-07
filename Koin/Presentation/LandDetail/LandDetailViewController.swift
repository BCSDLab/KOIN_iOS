//
//  DiningDetailViewController.swift
//  Koin
//
//  Created by 김나훈 on 3/14/24.
//

import Combine
import NMapsMap
import UIKit

final class LandDetailViewController: UIViewController {
    // MARK: - Properties
    
    private let viewModel: LandDetailViewModel
    private let inputSubject: PassthroughSubject<LandDetailViewModel.Input, Never> = .init()
    private var subscriptions: Set<AnyCancellable> = []
    
    // MARK: - UI Components
    
    private let scrollView: UIScrollView = {
        let scrollView = UIScrollView()
        return scrollView
    }()
    
    private let landNameLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.appFont(.pretendardMedium, size: 20)
        label.textAlignment = .center
        return label
    }()
    
    private let infoLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.appFont(.pretendardRegular, size: 15)
        label.text = "원룸 정보"
        return label
    }()
    
    private let infoView1: HouseInfoView = {
        let view = HouseInfoView(frame: .zero, text: "월세")
        return view
    }()
    
    private let infoView2: HouseInfoView = {
        let view = HouseInfoView(frame: .zero, text: "방 종류")
        return view
    }()
    
    private let infoView3: HouseInfoView = {
        let view = HouseInfoView(frame: .zero, text: "전세")
        return view
    }()
    
    private let infoView4: HouseInfoView = {
        let view = HouseInfoView(frame: .zero, text: "보증금")
        return view
    }()
    
    private let infoView5: HouseInfoView = {
        let view = HouseInfoView(frame: .zero, text: "층수")
        return view
    }()
    
    private let infoView6: HouseInfoView = {
        let view = HouseInfoView(frame: .zero, text: "관리비")
        return view
    }()
    
    private let infoView7: HouseInfoView = {
        let view = HouseInfoView(frame: .zero, text: "방 크기")
        return view
    }()
    
    private let infoView8: HouseInfoView = {
        let view = HouseInfoView(frame: .zero, text: "연락처")
        return view
    }()
    
    private let nonImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage.appImage(asset: .nonImage)
        return imageView
    }()
    
    private let imageCollectionView: LandImageCollectionView = {
        let flowLayout = UICollectionViewFlowLayout()
        flowLayout.scrollDirection = .horizontal
        let collectionView = LandImageCollectionView(frame: .zero, collectionViewLayout: flowLayout)
        collectionView.isScrollEnabled = false
        return collectionView
    }()
    
    private let indexLabel: UILabel = {
        let label = UILabel()
        label.layer.cornerRadius = 9
        label.layer.masksToBounds = true
        label.textAlignment = .center
        label.backgroundColor = UIColor.appColor(.neutral800).withAlphaComponent(0.5)
        label.textColor = UIColor.appColor(.neutral0)
        label.font = UIFont.appFont(.pretendardRegular, size: 12)
        return label
    }()
    
    private let prevButton: UIButton = {
        let button = UIButton()
        button.tintColor = UIColor.appColor(.neutral0)
        button.setImage(UIImage.appImage(symbol: .chevronLeft), for: .normal)
        return button
    }()
    
    private let nextButton: UIButton = {
        let button = UIButton()
        button.tintColor = UIColor.appColor(.neutral0)
        button.setImage(UIImage.appImage(symbol: .chevronRight), for: .normal)
        return button
    }()
    
    private let landOptionView: LandOptionView = {
        let view = LandOptionView()
        return view
    }()
    
    private let stackView1: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .horizontal
        stackView.distribution = .fillEqually
        return stackView
    }()
    
    private let stackView2: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .horizontal
        stackView.distribution = .fillEqually
        return stackView
    }()
    
    private let stackView3: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .horizontal
        stackView.distribution = .fillEqually
        return stackView
    }()
    
    private let stackView4: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .horizontal
        stackView.distribution = .fillEqually
        return stackView
    }()
    
    private let separateLine1: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor.appColor(.primary500)
        return view
    }()
    
    private let separateLine2: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor.appColor(.bus2)
        return view
    }()
    
    private let separateLine3: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor.appColor(.bus2)
        return view
    }()
    
    private let separateLine4: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor.appColor(.bus2)
        return view
    }()
    
    private let separateLine5: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor.appColor(.primary500)
        return view
    }()
    
    private let locationGuideLabel: UILabel = {
        let label = UILabel()
        label.text = "원룸 위치"
        label.font = UIFont.appFont(.pretendardMedium, size: 14)
        return label
    }()
    
    private let locationLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.appFont(.pretendardRegular, size: 13)
        label.textColor = UIColor.appColor(.neutral500)
        return label
    }()
    
    private let mapView: NMFMapView = {
        let mapView = NMFMapView()
        return mapView
    }()
    
    // MARK: - Initialization
    
    init(viewModel: LandDetailViewModel) {
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
        bind()
        configureView()
        inputSubject.send(.viewDidLoad)
        prevButton.addTarget(self, action: #selector(prevButtonTapped), for: .touchUpInside)
        nextButton.addTarget(self, action: #selector(nextButtonTapped), for: .touchUpInside)
    }
    
    // MARK: - Bind
    
    private func bind() {
        let outputSubject = viewModel.transform(with: inputSubject.eraseToAnyPublisher())
        outputSubject.receive(on: DispatchQueue.main).sink { [weak self] output in
            switch output {
            case let .showLandDetail(landDetailItem):
                self?.showLandDetail(landDetailItem)
            }
        }.store(in: &subscriptions)
        
        imageCollectionView.indexPublisher
            .sink { [weak self] text in
                self?.indexLabel.text = text
            }
            .store(in: &subscriptions)
    }
}

extension LandDetailViewController {

    private func showLocationOnMap(latitude: Double, longitude: Double) {
        let marker = NMFMarker()
        marker.position = NMGLatLng(lat: latitude, lng: longitude)
        marker.mapView = mapView
        marker.width = 25
        marker.height = 35
        let cameraUpdate = NMFCameraUpdate(scrollTo: NMGLatLng(lat: latitude, lng: longitude))
        let zoomUpdate = NMFCameraUpdate(zoomTo: 16)
        mapView.moveCamera(cameraUpdate)
        mapView.moveCamera(zoomUpdate)
    }
    
    private func showLandDetail(_ item: LandDetailItem) {
        landNameLabel.text = item.landName
        let infoViews = [infoView1, infoView2, infoView3, infoView4, infoView5, infoView6, infoView7, infoView8]

        for (index, infoView) in infoViews.enumerated() {
            if index < item.roomOptionInfo.count {
                infoView.setText(item.roomOptionInfo[index])
            }
        }
        if !item.imageUrls.isEmpty {
            imageCollectionView.setImageList(item.imageUrls)
            nonImageView.isHidden = true
        }
        else {
            [imageCollectionView, prevButton, nextButton, indexLabel].forEach {
                $0.isHidden = true
            }
        }
        locationLabel.text = item.address
        
        landOptionView.configure(item.isOptionExists)
        
        showLocationOnMap(latitude: item.latitude, longitude: item.longitude)
    }
    
    @objc func prevButtonTapped() {
        imageCollectionView.scrollToPreviousItem()
    }

    @objc func nextButtonTapped() {
        imageCollectionView.scrollToNextItem()
    }
}

extension LandDetailViewController {
    
    private func setUpLayOuts() {
        view.addSubview(scrollView)
        [landNameLabel, infoLabel, stackView1, stackView2, stackView3, stackView4, separateLine1, separateLine2, separateLine3, separateLine4, separateLine5, imageCollectionView, landOptionView, prevButton, nextButton, indexLabel, nonImageView, locationGuideLabel, locationLabel, mapView].forEach {
            scrollView.addSubview($0)
        }
        [infoView1, infoView2].forEach {
            stackView1.addArrangedSubview($0)
        }
        [infoView3, infoView4].forEach {
            stackView2.addArrangedSubview($0)
        }
        [infoView5, infoView6].forEach {
            stackView3.addArrangedSubview($0)
        }
        [infoView7, infoView8].forEach {
            stackView4.addArrangedSubview($0)
        }
    }
    
    private func setUpConstraints() {
        scrollView.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide.snp.top)
            make.leading.equalTo(view.snp.leading)
            make.trailing.equalTo(view.snp.trailing)
            make.bottom.equalTo(view.snp.bottom)
        }
        landNameLabel.snp.makeConstraints { make in
            make.top.equalTo(scrollView.snp.top).offset(30)
            make.width.equalTo(view.snp.width)
            make.centerX.equalTo(view.snp.centerX)
        }
        infoLabel.snp.makeConstraints { make in
            make.top.equalTo(landNameLabel.snp.bottom).offset(30)
            make.centerX.equalTo(view.snp.centerX)
        }
        stackView1.snp.makeConstraints { make in
            make.top.equalTo(infoLabel.snp.bottom).offset(30)
            make.leading.equalTo(view.snp.leading).offset(20)
            make.trailing.equalTo(view.snp.trailing).offset(-20)
            make.height.greaterThanOrEqualTo(40)
            make.centerX.equalTo(scrollView.snp.centerX)
        }
        stackView2.snp.makeConstraints { make in
            make.top.equalTo(stackView1.snp.bottom)
            make.leading.equalTo(view.snp.leading).offset(20)
            make.trailing.equalTo(view.snp.trailing).offset(-20)
            make.height.greaterThanOrEqualTo(40)
            make.centerX.equalTo(scrollView.snp.centerX)
        }
        stackView3.snp.makeConstraints { make in
            make.top.equalTo(stackView2.snp.bottom)
            make.leading.equalTo(view.snp.leading).offset(20)
            make.trailing.equalTo(view.snp.trailing).offset(-20)
            make.height.greaterThanOrEqualTo(40)
            make.centerX.equalTo(scrollView.snp.centerX)
        }
        stackView4.snp.makeConstraints { make in
            make.top.equalTo(stackView3.snp.bottom)
            make.leading.equalTo(view.snp.leading).offset(20)
            make.trailing.equalTo(view.snp.trailing).offset(-20)
            make.height.greaterThanOrEqualTo(40)
            make.centerX.equalTo(scrollView.snp.centerX)
        }
        separateLine1.snp.makeConstraints { make in
            make.top.equalTo(stackView1.snp.top)
            make.leading.equalTo(stackView1.snp.leading)
            make.trailing.equalTo(stackView1.snp.trailing)
            make.height.equalTo(1)
        }
        separateLine2.snp.makeConstraints { make in
            make.top.equalTo(stackView2.snp.top)
            make.leading.equalTo(stackView1.snp.leading)
            make.trailing.equalTo(stackView1.snp.trailing)
            make.height.equalTo(1)
        }
        separateLine3.snp.makeConstraints { make in
            make.top.equalTo(stackView3.snp.top)
            make.leading.equalTo(stackView1.snp.leading)
            make.trailing.equalTo(stackView1.snp.trailing)
            make.height.equalTo(1)
        }
        separateLine4.snp.makeConstraints { make in
            make.top.equalTo(stackView4.snp.top)
            make.leading.equalTo(stackView1.snp.leading)
            make.trailing.equalTo(stackView1.snp.trailing)
            make.height.equalTo(1)
        }
        separateLine5.snp.makeConstraints { make in
            make.top.equalTo(stackView4.snp.bottom)
            make.leading.equalTo(stackView1.snp.leading)
            make.trailing.equalTo(stackView1.snp.trailing)
            make.height.equalTo(1)
        }
        imageCollectionView.snp.makeConstraints { make in
            make.top.equalTo(stackView4.snp.bottom).offset(15)
            make.leading.equalTo(view.snp.leading).offset(70)
            make.trailing.equalTo(view.snp.trailing).offset(-70)
            make.height.equalTo(160)
            make.centerX.equalTo(view.snp.centerX)
        }
        indexLabel.snp.makeConstraints { make in
            make.centerX.equalTo(imageCollectionView.snp.centerX)
            make.bottom.equalTo(imageCollectionView.snp.bottom).offset(-10)
            make.width.equalTo(50)
            make.height.equalTo(20)
        }
        prevButton.snp.makeConstraints { make in
            make.leading.equalTo(imageCollectionView.snp.leading).offset(10)
            make.centerY.equalTo(imageCollectionView.snp.centerY)
            make.width.equalTo(30)
            make.height.equalTo(50)
        }
        nextButton.snp.makeConstraints { make in
            make.trailing.equalTo(imageCollectionView.snp.trailing).offset(-5)
            make.centerY.equalTo(imageCollectionView.snp.centerY)
            make.width.equalTo(30)
            make.height.equalTo(50)
        }
        nonImageView.snp.makeConstraints { make in
            make.top.equalTo(stackView4.snp.bottom).offset(20)
            make.leading.equalTo(view.snp.leading).offset(20)
            make.trailing.equalTo(view.snp.trailing).offset(-20)
            make.height.equalTo(200)
        }
        landOptionView.snp.makeConstraints { make in
            make.top.equalTo(nonImageView.snp.bottom).offset(20)
            make.leading.equalTo(view.snp.leading).offset(20)
            make.trailing.equalTo(view.snp.trailing).offset(-20)
            make.height.equalTo(300)
        }
        locationGuideLabel.snp.makeConstraints { make in
            make.top.equalTo(landOptionView.snp.bottom).offset(20)
            make.centerX.equalTo(view.snp.centerX)
        }
        locationLabel.snp.makeConstraints { make in
            make.top.equalTo(locationGuideLabel.snp.bottom).offset(20)
            make.centerX.equalTo(view.snp.centerX)
        }
        mapView.snp.makeConstraints { make in
            make.top.equalTo(locationLabel.snp.bottom).offset(30)
            make.leading.equalTo(view.snp.leading).offset(20)
            make.trailing.equalTo(view.snp.trailing).offset(-20)
            make.height.equalTo(200)
            make.bottom.equalTo(scrollView.contentLayoutGuide.snp.bottom).offset(-30)
        }
    }
    
    private func configureView() {
        setUpLayOuts()
        setUpConstraints()
        self.view.backgroundColor = .systemBackground
    }
}
