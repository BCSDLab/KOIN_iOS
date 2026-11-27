//
//  LandDetailViewController.swift
//  koin
//
//  Created by 홍기정 on 11/23/26.
//

import UIKit
import Combine
import SnapKit

final class LandDetailViewController: UIViewController {

    // MARK: - Properties
    private let viewModel: LandDetailViewModel
    private let inputSubject = PassthroughSubject<LandDetailViewModel.Input, Never>()
    private var subscriptions: Set<AnyCancellable> = []
    private var phone: String?

    // MARK: - UI Components
    private let scrollView = UIScrollView()
    private let contentStackView = UIStackView()
    private let titleStackView = UIStackView()
    private let badgeStackView = UIStackView()
    private let monthlyBadge = LandListBadgeView(style: .monthly)
    private let charterBadge = LandListBadgeView(style: .charter)
    private let nameLabel = UILabel()
    private let imageView = LandDetailImageView()
    private let infoView = LandDetailInfoView()
    private let locationStackView = UIStackView()
    private let locationTitleLabel = UILabel()
    private let mapView = LandMapView()
    private let bottomSheetContentView = LandDetailBottomSheetContentView()
    private let navigationBarView = UIView()
    private let navigationTitleLabel = UILabel()
    private let backButton = UIButton(type: .system)

    // MARK: - Initializer
    init(viewModel: LandDetailViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        configureView()
        configure(landRow: viewModel.landRow)
        presentLandDetailBottomSheet()
        bind()
        inputSubject.send(.viewDidLoad)
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: animated)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        navigationController?.setNavigationBarHidden(false, animated: animated)
    }
}

extension LandDetailViewController {
    private func bind() {
        viewModel.transform(with: inputSubject.eraseToAnyPublisher())
            .receive(on: DispatchQueue.main)
            .sink { [weak self] output in
                guard let self else { return }
                switch output {
                case let .updateLandDetail(landDetail):
                    configure(landDetail: landDetail)
                case let .showToastMessage(message):
                    showToastMessage(message: message)
                }
            }
            .store(in: &subscriptions)

        imageView.imageTappedPublisher
            .sink { [weak self] imageUrls, indexPath in
                self?.presentZoomedImage(imageUrls: imageUrls, indexPath: indexPath)
            }
            .store(in: &subscriptions)
        
        bottomSheetContentView.callTappedPublisher
            .sink { [weak self] in
                self?.inputSubject.send(.logEvent(EventParameter.EventLabel.RealEstate.roomDetailContactCallClick, "전화 문의하기"))
                self?.makePhoneCall()
            }
            .store(in: &subscriptions)
    }
}

extension LandDetailViewController {
    private func configure(landRow: LandRow) {
        monthlyBadge.isHidden = !landRow.isMonthlyAvailable
        charterBadge.isHidden = !landRow.isCharterAvailable
        badgeStackView.isHidden = !landRow.isMonthlyAvailable && !landRow.isCharterAvailable
        nameLabel.text = landRow.name
    }

    private func configure(landDetail: LandDetail) {
        phone = landDetail.phone
        nameLabel.text = landDetail.name
        imageView.configure(imageUrls: landDetail.imageUrls)
        infoView.configure(landDetail: landDetail)
        bottomSheetContentView.configure(landDetail: landDetail)
        if let markerKey = LandMarkerKey(id: landDetail.id, coordinate: landDetail.coordinate),
           let coordinate = landDetail.coordinate {
            mapView.configure(markerKey)
            mapView.focus(on: coordinate, animationDuration: 0)
        }
    }

    private func presentZoomedImage(imageUrls: [String], indexPath: IndexPath) {
        let zoomedImageViewController = ZoomedImageViewControllerB()
        zoomedImageViewController.configure(urls: imageUrls, selectedIndex: indexPath.row)
        present(zoomedImageViewController, animated: true)
    }
    
    @objc private func backButtonTapped() {
        navigationController?.popViewController(animated: true)
    }
    
    private func makePhoneCall() {
        guard let phone,
              let url = URL(string: "tel://" + phone.filter(\.isNumber)),
              UIApplication.shared.canOpenURL(url) else {
            return
        }
        UIApplication.shared.open(url)
    }
}

extension LandDetailViewController: PopLoggable {
    func sendPopLog(category: EventParameter.EventCategory) {
        let label: EventLabelType = category == .swipe
            ? EventParameter.EventLabel.RealEstate.roomCommonNavigationBackSwipe
            : EventParameter.EventLabel.RealEstate.roomCommonNavigationBackClick
        inputSubject.send(.logEvent(label, "뒤로가기", parameters: ["source_screen": "room_detail"]))
    }
}

extension LandDetailViewController {
    private func presentLandDetailBottomSheet() {
        var configuration = KoinBottomSheetConfiguration()
        configuration.style = .persistent
        configuration.behavior.isDraggable = false
        configuration.cornerRadius = 16
        configuration.onTargetFrameChange = { [weak self] sheetFrame in
            self?.updateScrollViewInset(sheetFrame: sheetFrame)
        }
        presentBottomSheet(bottomSheetContentView, configuration: configuration)
    }

    private func updateScrollViewInset(sheetFrame: CGRect) {
        let sheetTop = view.convert(sheetFrame, from: nil).minY
        let bottomInset = max(0, scrollView.frame.maxY - sheetTop) + 36
        scrollView.contentInset.bottom = bottomInset
        scrollView.verticalScrollIndicatorInsets.bottom = bottomInset
    }
}

extension LandDetailViewController {
    private func configureView() {
        setUpStyles()
        setUpLayouts()
        setUpConstraints()
    }

    private func setUpStyles() {
        view.backgroundColor = .appColor(.neutral0)
        additionalSafeAreaInsets.top = 44
        navigationBarView.backgroundColor = .appColor(.neutral0)
        navigationTitleLabel.do {
            $0.text = "복덕방"
            $0.font = .appFont(.pretendardMedium, size: 18)
            $0.textColor = .appColor(.neutral800)
        }
        backButton.do {
            $0.setImage(
                UIImage.appImage(symbol: .chevronLeft)?
                    .withConfiguration(UIImage.SymbolConfiguration(pointSize: 17, weight: .semibold, scale: .large)),
                for: .normal
            )
            $0.tintColor = .appColor(.neutral800)
            $0.accessibilityLabel = "뒤로가기"
            $0.addTarget(self, action: #selector(backButtonTapped), for: .touchUpInside)
        }
        contentStackView.do {
            $0.axis = .vertical
            $0.spacing = 12
            $0.alignment = .center
        }
        titleStackView.do {
            $0.axis = .vertical
            $0.spacing = 8
            $0.alignment = .leading
        }
        badgeStackView.do {
            $0.axis = .horizontal
            $0.spacing = 4
        }
        nameLabel.do {
            $0.font = .appFont(.pretendardMedium, size: 18)
            $0.textColor = .appColor(.neutral700)
            $0.numberOfLines = 0
        }
        locationStackView.do {
            $0.axis = .vertical
            $0.spacing = 16
        }
        locationTitleLabel.do {
            $0.text = "위치 정보"
            $0.font = .appFont(.pretendardMedium, size: 16)
            $0.textColor = .appColor(.neutral700)
        }
        mapView.isUserInteractionEnabled = false
    }

    private func setUpLayouts() {
        [scrollView, navigationBarView].forEach {
            view.addSubview($0)
        }
        [navigationTitleLabel, backButton].forEach {
            navigationBarView.addSubview($0)
        }
        scrollView.addSubview(contentStackView)
        [monthlyBadge, charterBadge].forEach {
            badgeStackView.addArrangedSubview($0)
        }
        [badgeStackView, nameLabel].forEach {
            titleStackView.addArrangedSubview($0)
        }
        [locationTitleLabel, mapView].forEach {
            locationStackView.addArrangedSubview($0)
        }
        [titleStackView, imageView, infoView, locationStackView].forEach {
            contentStackView.addArrangedSubview($0)
        }
        contentStackView.setCustomSpacing(24, after: imageView)
        contentStackView.setCustomSpacing(24, after: infoView)
    }

    private func setUpConstraints() {
        scrollView.snp.makeConstraints {
            $0.edges.equalTo(view.safeAreaLayoutGuide)
        }
        navigationBarView.snp.makeConstraints {
            $0.top.leading.trailing.equalToSuperview()
            $0.bottom.equalTo(view.safeAreaLayoutGuide.snp.top)
        }
        backButton.snp.makeConstraints {
            $0.leading.equalToSuperview().offset(8)
            $0.bottom.equalToSuperview()
            $0.size.equalTo(44)
        }
        navigationTitleLabel.snp.makeConstraints {
            $0.centerX.equalToSuperview()
            $0.centerY.equalTo(backButton)
        }
        contentStackView.snp.makeConstraints {
            $0.edges.equalTo(scrollView.contentLayoutGuide)
            $0.width.equalTo(scrollView.frameLayoutGuide)
        }
        [titleStackView, infoView, locationStackView].forEach { arrangedView in
            arrangedView.snp.makeConstraints {
                $0.width.equalToSuperview().offset(-48)
            }
        }
        imageView.snp.makeConstraints {
            $0.width.equalToSuperview()
        }
        nameLabel.snp.makeConstraints {
            $0.height.greaterThanOrEqualTo(29)
        }
        locationTitleLabel.snp.makeConstraints {
            $0.height.equalTo(26)
        }
        mapView.snp.makeConstraints {
            $0.height.equalTo(mapView.snp.width).multipliedBy(9.0 / 16.0)
        }
    }
}
