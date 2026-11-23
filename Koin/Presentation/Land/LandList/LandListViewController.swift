//
//  LandListViewController.swift
//  koin
//
//  Created by 홍기정 on 11/22/26.
//

import UIKit
import Combine
import SnapKit

final class LandListViewController: UIViewController {

    // MARK: - Properties
    private var landList: LandList = LandList.empty
    private let viewModel: LandListViewModel
    private let inputSubject = PassthroughSubject<LandListViewModel.Input, Never>()
    private var subscriptions: Set<AnyCancellable> = []
    private weak var bottomSheetController: KoinBottomSheetController?
    private var zoomControlBottomConstraint: Constraint?

    // MARK: - State
    private var focusedMarkerKey: LandMarkerKey? {
        didSet {
            if let focusedMarkerKey,
               let focusedRow = landList.rows.first(where: { $0.id == focusedMarkerKey.identifier }),
               let coordinate = focusedRow.coordinate {
                mapView.configure(focusedMarkerKey)
                bottomSheetController?.configuration.behavior.expandToFullScreenOnDrag = false
                bottomSheetContentView.showFocused(row: focusedRow)
                mapView.focus(on: coordinate)
            } else {
                let listFilter = listFilter
                self.listFilter = listFilter
                bottomSheetController?.configuration.behavior.expandToFullScreenOnDrag = true
                bottomSheetContentView.showList()
            }
        }
    }
    private var listFilter: LandListFilter = .all {
        didSet {
            let filteredList: LandList
            switch listFilter {
            case .all:
                filteredList = landList
            case .monthly:
                filteredList = LandList(rows: landList.rows.filter(\.isMonthlyAvailable))
            case .charter:
                filteredList = LandList(rows: landList.rows.filter(\.isCharterAvailable))
            }
            mapView.configure(filteredList.rows.compactMap {
                LandMarkerKey(id: $0.id, coordinate: $0.coordinate)
            })
            bottomSheetContentView.configure(filter: listFilter, rows: filteredList.rows)
        }
    }

    // MARK: - UI Components
    private let mapView = LandMapView()
    private let bottomSheetContentView = LandListBottomSheetContentView()
    private let zoomControlView = LandMapZoomControlView()
    private let navigationBarView = UIView()
    private let navigationTitleLabel = UILabel()
    private let backButton = UIButton(type: .system)
    private let searchButton = UIButton(type: .system)


    // MARK: - Initializer
    init(viewModel: LandListViewModel) {
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
        presentLandListBottomSheet()
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

extension LandListViewController {
    private func bind() {
        viewModel.transform(with: inputSubject.eraseToAnyPublisher())
            .receive(on: DispatchQueue.main)
            .sink { [weak self] output in
                guard let self else { return }
                switch output {
                case let .updateLandList(landList):
                    self.landList = landList
                    let listFilter = listFilter
                    self.listFilter = listFilter
                    if let medianCoordinate = landList.medianCoordinate {
                        mapView.focus(on: medianCoordinate, animationDuration: 0)
                    }
                case let .showToastMessage(message):
                    showToastMessage(message: message)
                }
            }
            .store(in: &subscriptions)

        mapView.markerTappedPublisher
            .receive(on: DispatchQueue.main)
            .sink { [weak self] focusedMarkerKey in
                self?.focusedMarkerKey = focusedMarkerKey
            }
            .store(in: &subscriptions)

        bottomSheetContentView.filterTappedPublisher
            .sink { [weak self] listFilter in
                self?.listFilter = listFilter
            }
            .store(in: &subscriptions)

        bottomSheetContentView.closeTappedPublisher
            .sink { [weak self] in
                self?.focusedMarkerKey = nil
            }
            .store(in: &subscriptions)

        bottomSheetContentView.rowTappedPublisher
            .merge(with: bottomSheetContentView.detailTappedPublisher)
            .sink { [weak self] landRow in
                self?.pushLandDetailViewController(landRow: landRow)
            }
            .store(in: &subscriptions)

        zoomControlView.zoomInTappedPublisher
            .sink { [weak self] in
                self?.mapView.zoomIn()
            }
            .store(in: &subscriptions)

        zoomControlView.zoomOutTappedPublisher
            .sink { [weak self] in
                self?.mapView.zoomOut()
            }
            .store(in: &subscriptions)
    }
}

extension LandListViewController {
    private func presentLandListBottomSheet() {
        var configuration = KoinBottomSheetConfiguration()
        configuration.style = .persistent
        configuration.behavior.expandToFullScreenOnDrag = true
        configuration.onTargetFrameChange = { [weak self] sheetFrame in
            self?.layoutAboveBottomSheet(sheetFrame: sheetFrame)
        }
        bottomSheetController = presentBottomSheet(bottomSheetContentView, configuration: configuration)
    }

    private func layoutAboveBottomSheet(sheetFrame: CGRect) {
        let sheetTop = view.convert(sheetFrame, from: nil).minY
        let isFullScreen = sheetTop <= mapView.frame.minY + 0.5
        zoomControlView.alpha = isFullScreen ? 0 : 1
        guard !isFullScreen else { return }
        mapView.setContentInset(bottom: max(0, mapView.frame.maxY - sheetTop))
        zoomControlBottomConstraint?.update(offset: sheetTop - view.bounds.height - 18)
        view.layoutIfNeeded()
    }
}

extension LandListViewController {
    private func pushLandDetailViewController(landRow: LandRow) {
        let landService = DefaultLandService()
        let landRepository = DefaultLandRepository(service: landService)
        let fetchLandDetailUseCase = DefaultFetchLandDetailUseCase(landRepository: landRepository)
        let viewModel = LandDetailViewModel(landRow: landRow, fetchLandDetailUseCase: fetchLandDetailUseCase)
        let viewController = LandDetailViewController(viewModel: viewModel)
        navigationController?.pushViewController(viewController, animated: true)
    }
}

extension LandListViewController {
    private func pushLandSearchViewController() {
        let landService = DefaultLandService()
        let landRepository = DefaultLandRepository(service: landService)
        let fetchLandListUseCase = DefaultFetchLandListUseCase(landRepository: landRepository)
        let viewModel = LandSearchViewModel(fetchLandListUseCase: fetchLandListUseCase)
        let viewController = LandSearchViewController(viewModel: viewModel)
        navigationController?.pushViewController(viewController, animated: true)
    }
    
    @objc private func searchButtonTapped() {
        pushLandSearchViewController()
    }
    
    @objc private func backButtonTapped() {
        navigationController?.popViewController(animated: true)
    }
}

extension LandListViewController {
    private func configureView() {
        setUpStyles()
        setUpLayouts()
        setUpConstraints()
    }

    private func setUpStyles() {
        additionalSafeAreaInsets.top = 44

        navigationBarView.backgroundColor = .appColor(.neutral0)

        navigationTitleLabel.text = "복덕방"
        navigationTitleLabel.font = .appFont(.pretendardMedium, size: 18)
        navigationTitleLabel.textColor = .appColor(.neutral800)

        let backImage = UIImage.appImage(symbol: .chevronLeft)?
            .withConfiguration(UIImage.SymbolConfiguration(pointSize: 17, weight: .semibold, scale: .large))
        backButton.setImage(backImage, for: .normal)
        backButton.tintColor = .appColor(.neutral800)
        backButton.accessibilityLabel = "뒤로가기"
        backButton.addTarget(self, action: #selector(backButtonTapped), for: .touchUpInside)
        searchButton.setImage(UIImage.appImage(asset: .landSearch)?.withRenderingMode(.alwaysOriginal), for: .normal)
        searchButton.accessibilityLabel = "검색"
        searchButton.addTarget(self, action: #selector(searchButtonTapped), for: .touchUpInside)
    }

    private func setUpLayouts() {
        [mapView, navigationBarView, zoomControlView].forEach {
            view.addSubview($0)
        }
        [navigationTitleLabel, backButton, searchButton].forEach {
            navigationBarView.addSubview($0)
        }
    }

    private func setUpConstraints() {
        mapView.snp.makeConstraints {
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
        searchButton.snp.makeConstraints {
            $0.trailing.equalToSuperview().offset(-8)
            $0.bottom.equalToSuperview()
            $0.size.equalTo(44)
        }
        navigationTitleLabel.snp.makeConstraints {
            $0.centerX.equalToSuperview()
            $0.centerY.equalTo(backButton)
        }
        zoomControlView.snp.makeConstraints {
            $0.trailing.equalToSuperview().offset(-12)
            zoomControlBottomConstraint = $0.bottom.equalToSuperview().constraint
        }
    }
}
