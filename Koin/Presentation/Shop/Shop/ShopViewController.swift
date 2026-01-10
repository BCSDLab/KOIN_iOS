//
//  ShopViewController.swift
//  koin
//
//  Created by 김나훈 on 10/3/24.
//

import Combine
import UIKit
import SnapKit

final class ShopViewController: UIViewController {
    
    // MARK: - Properties
    private let viewModel: ShopViewModel
    private let inputSubject = PassthroughSubject<ShopViewModel.Input, Never>()
    private var subscriptions = Set<AnyCancellable>()
    private var didTapBack = false
    
    // MARK: - UI Components
    private let shopCollectionView = ShopInfoCollectionView()
    
    // MARK: - Initialization
    init(viewModel: ShopViewModel) {
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
        navigationItem.title = "주변상점"
        configureView()
        bind()
        inputSubject.send(.viewDidLoad)
        hideKeyboardWhenTappedAround()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        configureNavigationBar(style: .transparentBlack)
        self.didTapBack = false
        inputSubject.send(.getUserScreenAction(Date(), .enterVC))
        inputSubject.send(.getUserScreenAction(Date(), .beginEvent, .shopCategories))
        inputSubject.send(.getUserScreenAction(Date(), .beginEvent, .shopCategoriesBack))
        inputSubject.send(.getUserScreenAction(Date(), .beginEvent, .shopClick))
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        guard !didTapBack, (self.parent?.isMovingFromParent ?? false) else { return }
        didTapBack = true
        
        let previousPage = viewModel.selectedCategoryName
        let currentPage = "메인"
        let isSwipe = navigationController?.transitionCoordinator?.isInteractive ?? false
        let eventCategory: EventParameter.EventCategory = isSwipe ? .swipe : .click
        inputSubject.send(.getUserScreenAction(Date(), .endEvent, .shopCategoriesBack))
        inputSubject.send(.logEvent(EventParameter.EventLabel.Business.shopCategoriesBack, eventCategory, currentPage, previousPage, nil, nil, .shopCategoriesBack))
        inputSubject.send(.getUserScreenAction(Date(), .endEvent, .shopCategories))
        shopCollectionView.stopAutoScroll()
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    // MARK: - Binding
    private func bind() {
        let outputSubject = viewModel.transform(with: inputSubject.eraseToAnyPublisher())
        
        outputSubject.receive(on: DispatchQueue.main)
            .sink { [weak self] output in
            guard let self = self else { return }
            switch output {
            case let .changeFilteredShops(shops, id):
                self.updateFilteredShops(shops)
                self.updateFilteredCategory(id)
            case let .putImage(response):
                self.putImage(data: response)
            case let .updateEventShops(eventShops):
                self.updateEventShops(eventShops)
            case let .updateSortButtonTitle(newTitle):
                self.shopCollectionView.updateSortButtonTitle(newTitle)
            default: break
            }
        }.store(in: &subscriptions)

        
        shopCollectionView.sortOptionDidChangePublisher.sink { [weak self] sortType in
            self?.inputSubject.send(.sortOptionDidChange(sortType))
        }.store(in: &subscriptions)

        shopCollectionView.selectedCategoryPublisher.sink { [weak self] categoryId in
            guard let self else { return }
            
            let previousPage = self.viewModel.selectedCategoryName
            let currentPage  = self.viewModel.categoryName(for: categoryId)
            
            self.inputSubject.send(.getUserScreenAction(Date(), .endEvent, .shopCategories))
            self.inputSubject.send(.logEvent(EventParameter.EventLabel.Business.shopCategories, .click, currentPage, previousPage, nil, nil, .shopCategories))
            
            self.inputSubject.send(.getUserScreenAction(Date(), .beginEvent, .shopCategories))
            self.inputSubject.send(.changeCategory(categoryId))
            
            self.inputSubject.send(.getUserScreenAction(Date(), .endEvent, .shopClick))
            self.inputSubject.send(.getUserScreenAction(Date(), .beginEvent, .shopClick))
        }.store(in: &subscriptions)
        
        shopCollectionView.cellTapPublisher.sink { [weak self] shopId, shopName in
            let service = DefaultShopService()
            let repository = DefaultShopRepository(service: service)
            
            let fetchOrderShopSummaryFromShopUseCase = DefaultFetchOrderShopSummaryFromShopUseCase(repository: repository)
            let fetchOrderShopMenusAndGroupsFromShopUseCase = DefaultFetchOrderShopMenusAndGroupsFromShopUseCase(shopRepository: repository)
            let fetchShopDataUseCase = DefaultFetchShopDataUseCase(shopRepository: repository)
            let logAnalyticsEventUseCase = DefaultLogAnalyticsEventUseCase(repository: GA4AnalyticsRepository(service: GA4AnalyticsService()))
            let getUserScreenTimeUseCase = DefaultGetUserScreenTimeUseCase()
            let previousPage = self?.viewModel.selectedCategoryName ?? "알 수 없음" 
            let viewModel = ShopSummaryViewModel(fetchOrderShopSummaryFromShopUseCase: fetchOrderShopSummaryFromShopUseCase,
                                                 fetchOrderShopMenusAndGroupsFromShopUseCase: fetchOrderShopMenusAndGroupsFromShopUseCase,
                                                 fetchShopDataUseCase: fetchShopDataUseCase,
                                                 logAnalyticsEventUseCase: logAnalyticsEventUseCase,
                                                 getUserScreenTimeUseCase: getUserScreenTimeUseCase,
                                                 shopId: shopId,
                                                 shopName: shopName)
            let viewController = ShopSummaryViewController(viewModel: viewModel, backCategoryName: previousPage)
            viewController.title = shopName
            let currentPage = shopName
            self?.inputSubject.send(.getUserScreenAction(Date(), .endEvent, .shopClick))
            self?.inputSubject.send(.logEvent(EventParameter.EventLabel.Business.shopClick, .click, currentPage, previousPage, nil, nil, .shopClick))

            self?.navigationController?.pushViewController(viewController, animated: true)
        }.store(in: &subscriptions)
        
        shopCollectionView.makeScrollLogPublisher.sink { [weak self] in
            self?.makeScrollLog()
        }.store(in: &subscriptions)
        
        shopCollectionView.searchBarButtonTappedPublisher.sink { [weak self] in
            self?.searchBarButtonTapped()
        }.store(in: &subscriptions)
        
        shopCollectionView.sortButtonTappedPublisher.sink { [weak self] in
            self?.sortButtonTapped()
        }.store(in: &subscriptions)
        
        shopCollectionView.openShopToggleButtonPublisher.sink { [weak self] isSelected in
            self?.handleOpenShopToggle(isSelected: isSelected)
        }.store(in: &subscriptions)
    }
}

// MARK: - @objc
extension ShopViewController {
    @objc private func searchBarButtonTapped() {
        let shopService = DefaultShopService()
        let shopRepository = DefaultShopRepository(service: shopService)
        let fetchSearchShopUseCase = DefaultFetchSearchShopUseCase(repository: shopRepository)
        let logAnalyticsEventUseCase = DefaultLogAnalyticsEventUseCase(repository: GA4AnalyticsRepository(service: GA4AnalyticsService()))
        let viewModel = ShopSearchViewModel(fetchSearchShopUseCase: fetchSearchShopUseCase,
                                            logAnalyticsEventUseCase: logAnalyticsEventUseCase,
                                            selectedCategoryName: viewModel.selectedCategoryName)
        let viewController = ShopSearchViewController(viewModel: viewModel)
        navigationController?.pushViewController(viewController, animated: true)
    }

    @objc private func sortButtonTapped() {
        guard presentedViewController == nil else { return }
        
        let bottomSheetViewController = ShopSortOptionSheetViewController(current: viewModel.currentSortType)
        
        let categoryName = viewModel.selectedCategoryName

        bottomSheetViewController.onOptionSelected = { [weak self] sort in
            self?.inputSubject.send(.sortOptionDidChange(sort))
            let value: String
            switch sort {
            case .basic: value = "check_default_\(categoryName)"
            case .review: value = "check_review_\(categoryName)"
            case .rating: value = "check_star_\(categoryName)"
            }
            self?.inputSubject.send(.logEventDirect(EventParameter.EventLabel.Business.shopCan, .click, value))
        }
        
        bottomSheetViewController.modalPresentationStyle = .pageSheet
        if let sheet = bottomSheetViewController.sheetPresentationController {
            if #available(iOS 16.0, *) {
                let detent = UISheetPresentationController.Detent.custom(identifier: .init("fixed233")) { _ in 233 }
                sheet.detents = [detent]
                sheet.selectedDetentIdentifier = detent.identifier
            } else {
                sheet.detents = [.medium()]
            }
            sheet.prefersGrabberVisible = true
            sheet.preferredCornerRadius = 32
        }
        present(bottomSheetViewController, animated: true)
    }
}

extension ShopViewController {
    private func handleOpenShopToggle(isSelected: Bool) {
        let categoryName = viewModel.selectedCategoryName
        let value = "check_open_\(categoryName)"
        inputSubject.send(.logEventDirect(EventParameter.EventLabel.Business.shopCan, .click, value))
        inputSubject.send(.filterOpenShops(isSelected))
    }

    private func updateFilteredShops(_ shops: [Shop]) {
        shopCollectionView.updateShop(shops)
    }
    private func updateFilteredCategory(_ id: Int) {
        shopCollectionView.updateFilteredCategory(id)
    }
    private func putImage(data: ShopCategoryDto) {
        shopCollectionView.putImage(data: data)
    }
    private func updateEventShops(_ eventShops: [EventDto]) {
        shopCollectionView.updateEventShops(eventShops)
    }
    private func makeScrollLog() {
        let categoryName = viewModel.selectedCategoryName
        inputSubject.send(.logEventDirect(EventParameter.EventLabel.Business.shopCategories, .scroll, "scroll in \(categoryName)"))
    }

}

extension ShopViewController {
    private func setUpLayOuts() {
        [shopCollectionView].forEach {
            view.addSubview($0)
        }
    }
    
    private func setUpConstraints() {
        shopCollectionView.snp.makeConstraints {
            $0.top.equalToSuperview()
            $0.leading.equalToSuperview()
            $0.trailing.equalToSuperview()
            $0.bottom.equalToSuperview().offset(-32)
        }
    }
    
    private func configureView() {
        setUpLayOuts()
        setUpConstraints()
        view.backgroundColor = UIColor.appColor(.newBackground)
    }
}
