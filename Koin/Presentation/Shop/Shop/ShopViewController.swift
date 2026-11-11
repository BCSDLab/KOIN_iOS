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
        configureNavigationBar(style: .newBackground)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
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
            }
        }.store(in: &subscriptions)

        shopCollectionView.sortOptionDidChangePublisher.sink { [weak self] sortType in
            self?.inputSubject.send(.sortOptionDidChange(sortType))
        }.store(in: &subscriptions)

        shopCollectionView.selectedCategoryPublisher.sink { [weak self] categoryId in
            guard let self else { return }
            
            if categoryId != self.viewModel.selectedId {
                self.inputSubject.send(.logEvent(EventParameter.EventLabel.Shop.shopListFilterCategoryClick, self.viewModel.categoryName(for: categoryId)))
            }
            
            self.inputSubject.send(.changeCategory(categoryId))
            
        }.store(in: &subscriptions)
        
        shopCollectionView.cellTapPublisher.sink { [weak self] shopId, shopName in
            let service = DefaultShopService()
            let repository = DefaultShopRepository(service: service)
            
            let fetchShopSummaryUseCase = DefaultFetchShopSummaryUseCase(shopRepository: repository)
            let logAnalyticsEventUseCase = DefaultLogAnalyticsEventUseCase(repository: GA4AnalyticsRepository(service: GA4AnalyticsService()))
            let viewModel = ShopSummaryViewModel(
                fetchShopSummaryUseCase: fetchShopSummaryUseCase,
                logAnalyticsEventUseCase: logAnalyticsEventUseCase,
                shopId: shopId,
                shopName: shopName
            )
            let viewController = ShopSummaryViewController(viewModel: viewModel)
            viewController.title = shopName
            let currentPage = shopName
            self?.inputSubject.send(.logEvent(EventParameter.EventLabel.Shop.shopListShopDetailEntryClick, currentPage))

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

extension ShopViewController: PopLoggable {
    func sendPopLog(category: EventParameter.EventCategory) {
        let label: EventLabelType = category == .swipe
            ? EventParameter.EventLabel.Shop.shopListNavigationBackSwipe
            : EventParameter.EventLabel.Shop.shopListNavigationBackClick
        inputSubject.send(.logEvent(label, "메인"))
    }
}

// MARK: - @objc
extension ShopViewController {
    @objc private func searchBarButtonTapped() {
        inputSubject.send(.logEvent(EventParameter.EventLabel.Shop.shopListSearchClick, viewModel.selectedCategoryName))
        let shopService = DefaultShopService()
        let shopRepository = DefaultShopRepository(service: shopService)
        let fetchSearchShopUseCase = DefaultFetchSearchShopUseCase(repository: shopRepository)
        let logAnalyticsEventUseCase = DefaultLogAnalyticsEventUseCase(repository: GA4AnalyticsRepository(service: GA4AnalyticsService()))
        let viewModel = ShopSearchViewModel(fetchSearchShopUseCase: fetchSearchShopUseCase,
                                            logAnalyticsEventUseCase: logAnalyticsEventUseCase)
        let viewController = ShopSearchViewController(viewModel: viewModel)
        navigationController?.pushViewController(viewController, animated: true)
    }

    @objc private func sortButtonTapped() {
        let contentView = ShopSortOptionSheetView(current: viewModel.currentSortType)

        contentView.onOptionSelected = { [weak self] sort in
            self?.inputSubject.send(.sortOptionDidChange(sort))
            self?.inputSubject.send(.logEvent(EventParameter.EventLabel.Shop.shopListFilterSortSelect, sort.title))
        }

        presentBottomSheet(contentView, configuration: .init(style: .modal(dimAlpha: 0.2), cornerRadius: 32))
    }
}

extension ShopViewController {
    private func handleOpenShopToggle(isSelected: Bool) {
        if isSelected {
            inputSubject.send(.logEvent(EventParameter.EventLabel.Shop.shopListFilterQuickFilterSelect, "영업중"))
        }
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
        inputSubject.send(.logEvent(EventParameter.EventLabel.Shop.shopListShopListScroll, categoryName))
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
            $0.bottom.equalToSuperview()
        }
    }
    
    private func configureView() {
        setUpLayOuts()
        setUpConstraints()
        view.backgroundColor = UIColor.appColor(.newBackground)
    }
}
