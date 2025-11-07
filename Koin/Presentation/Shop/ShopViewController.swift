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
    
    private let navigationControllerDelegate: UINavigationController?
    
    private var categories: [ShopCategory] = []
    private var currentCategoryId: Int = 0
    
    private var didTapBack = false
    
    // MARK: - UI Components
    private let scrollView = UIScrollView()
    private let contentView = UIView()
    
    private let categoryCollectionView = OrderCategoryCollectionView(frame: .zero, collectionViewLayout: UICollectionViewFlowLayout())
    
    private let searchTextField = UITextField().then {
        $0.placeholder = "검색어를 입력해주세요."
        $0.font = UIFont.appFont(.pretendardRegular, size: 14)
        $0.tintColor = UIColor.appColor(.neutral500)
        $0.textColor = UIColor.appColor(.neutral800)
        $0.backgroundColor = .white
        $0.layer.cornerRadius = 12
        $0.layer.masksToBounds = true
        
        let imageView = UIImageView(image: UIImage.appImage(asset: .search)?.withRenderingMode(.alwaysTemplate))
        imageView.tintColor = UIColor.appColor(.neutral500)
        imageView.contentMode = .scaleAspectFit
        imageView.frame = CGRect(x: 0, y: 0, width: 20, height: 20)
        
        let iconContainer = UIView(frame: CGRect(x: 0, y: 0, width: 32, height: 32))
        iconContainer.addSubview(imageView)
        imageView.center = iconContainer.center
        
        $0.leftView = iconContainer
        $0.leftViewMode = .always
        
        let paddingView = UIView(frame: CGRect(x: 0, y: 0, width: 12, height: 32))
        $0.rightView = paddingView
        $0.rightViewMode = .always
        
        $0.layer.shadowColor = UIColor.black.cgColor
        $0.layer.shadowOffset = CGSize(width: 0, height: 2)
        $0.layer.shadowRadius = 4
        $0.layer.shadowOpacity = 0.04
        $0.layer.masksToBounds = false
        
        $0.setNeedsLayout()
    }
    
    private let searchedShopCollectionView = RelatedShopCollectionView(
        frame: .zero,
        collectionViewLayout: UICollectionViewFlowLayout()
    ).then {
        guard let layout = $0.collectionViewLayout as? UICollectionViewFlowLayout else { return }
        layout.scrollDirection = .vertical
        let screenWidth = UIScreen.main.bounds.width
        let cellWidth = screenWidth - 32
        layout.itemSize = CGSize(width: cellWidth, height: 40)
        layout.minimumLineSpacing = 0
        $0.isScrollEnabled = false
        $0.isHidden = true
    }
    
    private let dimView = UIView().then {
        $0.backgroundColor = UIColor.appColor(.neutral800).withAlphaComponent(0.7)
        $0.isHidden = true
    }
    
    private let sortButton = UIButton(type: .system).then {
        var config = UIButton.Configuration.plain()
        
        var titleAttribute = AttributedString("기본순")
        titleAttribute.font = UIFont.appFont(.pretendardBold, size: 14)
        titleAttribute.foregroundColor = UIColor.appColor(.new500)
        config.attributedTitle = titleAttribute
        
        if let img = UIImage.appImage(asset: .chevronDown)?.withRenderingMode(.alwaysTemplate) {
            config.image = img
            config.imagePlacement = .trailing
            config.imagePadding = 6
        }
        
        config.contentInsets = .init(top: 6, leading: 8, bottom: 6, trailing: 8)
        
        config.background.backgroundColor = UIColor.appColor(.newBackground)
        config.background.cornerRadius = 24
        config.background.strokeWidth = 1
        config.background.strokeColor = UIColor.appColor(.new500)
        
        $0.configuration = config
        $0.tintColor = .appColor(.new500)
        $0.sizeToFit()
    }
    
    private let openShopToggleButton = UIButton(type: .custom).then { button in
        var config = UIButton.Configuration.plain()
        config.image = UIImage.appImage(asset: .filterIcon1)?.withRenderingMode(.alwaysTemplate)
        config.imagePadding = 6
        config.imagePlacement = .leading
        config.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: 12, bottom: 0, trailing: 12)
        button.configuration = config
        
        button.configurationUpdateHandler = { button in
            let selectedBackgroundColor = UIColor.appColor(.new500)
            let unselectedBackgroundColor = UIColor.white
            let selectedTitleColor = UIColor.white
            let unselectedTitleColor = UIColor.appColor(.neutral400)
            
            var newConfig = button.configuration
            let color = button.isSelected ? selectedTitleColor : unselectedTitleColor
            
            newConfig?.background.backgroundColor = button.isSelected ? selectedBackgroundColor : unselectedBackgroundColor
            newConfig?.baseForegroundColor = color
            newConfig?.background.cornerRadius = 17
            
            newConfig?.attributedTitle = AttributedString("영업중", attributes: AttributeContainer([
                .font: UIFont.appFont(.pretendardBold, size: 14),
                .foregroundColor: color
            ]))
            
            button.configuration = newConfig
        }
        
        button.layer.shadowColor = UIColor.black.cgColor
        button.layer.shadowOffset = CGSize(width: 0, height: 2)
        button.layer.shadowRadius = 4
        button.layer.shadowOpacity = 0.04
        button.layer.masksToBounds = false
    }
    
    private let eventShopCollectionView = EventShopCollectionView(
        frame: .zero,
        collectionViewLayout: UICollectionViewFlowLayout()
    ).then {
        guard let layout = $0.collectionViewLayout as? UICollectionViewFlowLayout else { return }
        layout.itemSize = CGSize(width: UIScreen.main.bounds.width - 48, height: 100)
        layout.scrollDirection = .horizontal
        $0.isHidden = true
    }
    
    private let eventIndexLabel = UILabel().then {
        $0.font = UIFont.appFont(.pretendardRegular, size: 10)
        $0.textColor = .appColor(.neutral0)
        $0.backgroundColor = UIColor.appColor(.neutral800).withAlphaComponent(0.6)
        $0.layer.cornerRadius = 5
        $0.layer.masksToBounds = true
        $0.textAlignment = .center
        $0.isHidden = true
    }
    
    private let shopCollectionView = ShopInfoCollectionView()
    
    // MARK: - Initialization
    init(viewModel: ShopViewModel, navigationControllerDelegate: UINavigationController? = nil) {
        self.viewModel = viewModel
        self.navigationControllerDelegate = navigationControllerDelegate
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
        setAddTarget()
        searchTextField.delegate = self
        scrollView.delegate = self
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        configureNavigationBar(style: .order)
        self.didTapBack = false
        inputSubject.send(.getUserScreenAction(Date(), .enterVC))
        inputSubject.send(.getUserScreenAction(Date(), .beginEvent, .shopCategories))
        inputSubject.send(.getUserScreenAction(Date(), .beginEvent, .shopCategoriesBack))
        inputSubject.send(.getUserScreenAction(Date(), .beginEvent, .shopClick))
        self.currentCategoryId = viewModel.selectedId
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        guard !didTapBack, (self.parent?.isMovingFromParent ?? false) else { return }
        didTapBack = true
        
        let previousPage = getCategoryName(for: currentCategoryId)
        let currentPage = "메인"
        let isSwipe = navigationController?.transitionCoordinator?.isInteractive ?? false
        let eventCategory: EventParameter.EventCategory = isSwipe ? .swipe : .click
        inputSubject.send(.getUserScreenAction(Date(), .endEvent, .shopCategoriesBack))
        inputSubject.send(.logEvent(EventParameter.EventLabel.Business.shopCategoriesBack, eventCategory, currentPage, previousPage, nil, nil, .shopCategoriesBack))
        inputSubject.send(.getUserScreenAction(Date(), .endEvent, .shopCategories))
        eventShopCollectionView.stopAutoScroll()
        self.currentCategoryId = viewModel.selectedId
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
            case let .showSearchedResult(result):
                self.searchedShopCollectionView.updateShop(keywords: result)
            case let .updateSortButtonTitle(newTitle):
                var config = self.sortButton.configuration ?? .plain()
                var attribute = AttributedString(newTitle)
                attribute.font = UIFont.appFont(.pretendardBold, size: 14)
                attribute.foregroundColor = UIColor.appColor(.new500)
                config.attributedTitle = attribute
                self.sortButton.configuration = config
            default: break
            }
        }.store(in: &subscriptions)

        eventShopCollectionView.scrollPublisher.sink { [weak self] index in
            self?.eventIndexLabel.text = index
        }.store(in: &subscriptions)

        shopCollectionView.sortOptionDidChangePublisher.sink { [weak self] sortType in
            self?.inputSubject.send(.sortOptionDidChange(sortType))
        }.store(in: &subscriptions)

        categoryCollectionView.selectedCategoryPublisher.sink { [weak self] categoryId in
            guard let self else { return }
            
            let previousPage = self.getCategoryName(for: self.currentCategoryId)
            let currentPage  = self.getCategoryName(for: categoryId)
            
            self.inputSubject.send(.getUserScreenAction(Date(), .endEvent, .shopCategories))
            self.inputSubject.send(.logEvent(EventParameter.EventLabel.Business.shopCategories, .click, currentPage, previousPage, nil, nil, .shopCategories))
            
            self.currentCategoryId = categoryId
            
            self.inputSubject.send(.getUserScreenAction(Date(), .beginEvent, .shopCategories))
            self.inputSubject.send(.changeCategory(categoryId))
            
            self.inputSubject.send(.getUserScreenAction(Date(), .endEvent, .shopClick))
            self.inputSubject.send(.getUserScreenAction(Date(), .beginEvent, .shopClick))
        }.store(in: &subscriptions)
        
        shopCollectionView.cellTapPublisher.sink { [weak self] shopId, shopName in
            let service = DefaultShopService()
            let repository = DefaultShopRepository(service: service)
            
            let fetchOrderShopSummaryFromShopUseCase = DefaultFetchOrderShopSummaryFromShopUseCase(repository: repository)
            let fetchOrderShopMenusGroupsFromShopUseCase = DefaultFetchOrderShopMenusGroupsFromShopUseCase(repository: repository)
            let fetchOrderShopMenusFromShopUseCase = DefaultFetchOrderShopMenusFromShopUseCase(shopRepository: repository)
            let fetchShopDataUseCase = DefaultFetchShopDataUseCase(shopRepository: repository)
            let logAnalyticsEventUseCase = DefaultLogAnalyticsEventUseCase(repository: GA4AnalyticsRepository(service: GA4AnalyticsService()))
            let getUserScreenTimeUseCase = DefaultGetUserScreenTimeUseCase()
            let previousPage = self?.getCategoryName(for: self?.currentCategoryId ?? 0) ?? "알 수 없음"
            let viewModel = ShopSummaryViewModel(fetchOrderShopSummaryFromShopUseCase: fetchOrderShopSummaryFromShopUseCase,
                                                fetchOrderShopMenusGroupsFromShopUseCase: fetchOrderShopMenusGroupsFromShopUseCase,
                                                fetchOrderShopMenusFromShopUseCase: fetchOrderShopMenusFromShopUseCase,
                                                fetchShopDataUseCase: fetchShopDataUseCase,
                                                 logAnalyticsEventUseCase: logAnalyticsEventUseCase,
                                                 getUserScreenTimeUseCase: getUserScreenTimeUseCase,
                                                shopId: shopId)
            let viewController = ShopSummaryViewController(viewModel: viewModel, isFromOrder: false, orderableShopId: nil, backCategoryName: previousPage)
            viewController.title = shopName
            let currentPage = shopName
            self?.inputSubject.send(.getUserScreenAction(Date(), .endEvent, .shopClick))
            self?.inputSubject.send(.logEvent(EventParameter.EventLabel.Business.shopClick, .click, currentPage, previousPage, nil, nil, .shopClick))

            
            self?.navigationControllerDelegate?.pushViewController(viewController, animated: true)
        }
        .store(in: &subscriptions)
    }
    
    private func setAddTarget() {
        searchTextField.addTarget(self, action: #selector(textFieldDidChange(_:)), for: .editingChanged)
        
        searchTextField.addTarget(self, action: #selector(searchDidBegin(_:)), for: .editingDidBegin)

        
        sortButton.addTarget(self, action: #selector(sortButtonTapped), for: .touchUpInside)
        
        openShopToggleButton.addAction(UIAction { [weak self] _ in self?.handleOpenShopToggle() }, for: .touchUpInside)
    }
}

// MARK: - @objc
extension ShopViewController {
    @objc private func textFieldDidChange(_ textField: UITextField) {
        guard let text = textField.text else { return }
        searchedShopCollectionView.isHidden = false
        dimView.isHidden = false
        inputSubject.send(.searchTextChanged(text))
    }
    
    @objc private func searchDidBegin(_ textField: UITextField) {
        let currentCategoryName = getCategoryName(for: currentCategoryId)

        inputSubject.send(.logEventDirect(EventParameter.EventLabel.Business.shopCategoriesSearch, .click, "search in \(currentCategoryName)"))
    }


    @objc private func dismissCollectionView(_ sender: UITapGestureRecognizer) {
        if !searchTextField.frame.contains(sender.location(in: view)) {
            searchedShopCollectionView.isHidden = true
            dimView.isHidden = true
            searchTextField.resignFirstResponder()
        }
    }

    @objc private func sortButtonTapped() {
        guard presentedViewController == nil else { return }
        
        let bottomSheetViewController = ShopSortOptionSheetViewController(current: viewModel.currentSortType)
        
        let categoryName = getCategoryName(for: currentCategoryId)

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
    private func handleOpenShopToggle() {
        openShopToggleButton.isSelected.toggle()
        let categoryName = getCategoryName(for: currentCategoryId)
        let value = "check_open_\(categoryName)"
        inputSubject.send(.logEventDirect(EventParameter.EventLabel.Business.shopCan, .click, value))
        inputSubject.send(.filterOpenShops(openShopToggleButton.isSelected))
    }

    private func updateFilteredShops(_ shops: [Shop]) {
        shopCollectionView.updateShop(shops)
        shopCollectionView.snp.updateConstraints { $0.height.equalTo(shopCollectionView.calculateShopListHeight()) }
    }

    private func updateFilteredCategory(_ id: Int) {
        categoryCollectionView.updateCategory(id)
    }

    private func putImage(data: ShopCategoryDto) {
        self.categories = data.shopCategories
        categoryCollectionView.updateCategories(data.shopCategories)
    }

    private func updateEventShops(_ eventShops: [EventDto]) {
        let eventShops: [EventDto] = []
        eventShopCollectionView.isHidden = eventShops.isEmpty
        eventIndexLabel.isHidden = eventShops.isEmpty
        if !eventShops.isEmpty {
            shopCollectionView.snp.remakeConstraints {
                $0.top.equalTo(eventShopCollectionView.snp.bottom).offset(14)
                $0.leading.equalToSuperview().offset(24)
                $0.trailing.equalToSuperview().offset(-24)
                $0.height.equalTo(1)
                $0.bottom.equalToSuperview().offset(-32)
            }
            eventShopCollectionView.setEventShops(eventShops)
            eventIndexLabel.text = "1/\(eventShops.count)"
        }
    }
    
    private func getCategoryName(for id: Int) -> String {
        if id == 0 { return "전체보기" }
        return categories.first(where: { $0.id == id })?.name ?? "알 수 없음"
    }
}

// MARK: - Configure View
extension ShopViewController {
    private func setUpLayOuts() {
        view.addSubview(scrollView)
        scrollView.addSubview(contentView)
        [categoryCollectionView, searchTextField, searchedShopCollectionView, dimView, sortButton, openShopToggleButton, eventShopCollectionView, eventIndexLabel, shopCollectionView].forEach {
            contentView.addSubview($0)
        }
    }
    
    private func setUpConstraints() {
        scrollView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }

        contentView.snp.makeConstraints {
            $0.edges.equalToSuperview()
            $0.width.equalToSuperview()
        }

        searchTextField.snp.makeConstraints {
            $0.top.equalToSuperview().offset(20)
            $0.leading.trailing.equalToSuperview().inset(16)
            $0.height.equalTo(40)
        }

        searchedShopCollectionView.snp.makeConstraints {
            $0.top.equalTo(searchTextField.snp.bottom)
            $0.leading.trailing.equalToSuperview()
            $0.bottom.equalToSuperview()
        }

        dimView.snp.makeConstraints {
            $0.top.equalTo(searchTextField.snp.bottom)
            $0.leading.trailing.equalTo(searchedShopCollectionView)
            $0.bottom.equalToSuperview()
        }

        categoryCollectionView.snp.makeConstraints {
            $0.top.equalTo(searchTextField.snp.bottom).offset(12)
            $0.leading.trailing.equalToSuperview()
            $0.height.equalTo(71)
        }

        sortButton.snp.makeConstraints {
            $0.top.equalTo(categoryCollectionView.snp.bottom).offset(24)
            $0.leading.equalToSuperview().offset(16)
            $0.width.greaterThanOrEqualTo(75)
            $0.height.equalTo(34)
        }

        openShopToggleButton.snp.makeConstraints {
            $0.leading.equalTo(sortButton.snp.trailing).offset(16)
            $0.centerY.equalTo(sortButton)
            $0.height.equalTo(34)
            $0.width.greaterThanOrEqualTo(74)
        }

        eventShopCollectionView.snp.makeConstraints {
            $0.top.equalTo(openShopToggleButton.snp.bottom).offset(24)
            $0.leading.trailing.equalToSuperview()
            $0.height.equalTo(100)
        }
        
        eventIndexLabel.snp.makeConstraints {
            $0.bottom.equalTo(eventShopCollectionView.snp.bottom).offset(-12)
            $0.trailing.equalToSuperview().offset(-44)
            $0.width.greaterThanOrEqualTo(40)
            $0.height.equalTo(14)
        }
        
        shopCollectionView.snp.makeConstraints {
            $0.top.equalTo(openShopToggleButton.snp.bottom).offset(24)
            $0.leading.equalToSuperview().offset(24)
            $0.trailing.equalToSuperview().offset(-24)
            $0.height.equalTo(1)
            $0.bottom.equalToSuperview().offset(-32)
        }
    }
    
    private func configureView() {
        setUpLayOuts()
        setUpConstraints()
        view.backgroundColor = UIColor.appColor(.newBackground)
    }
}

extension ShopViewController: UIScrollViewDelegate {
    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        if !decelerate && scrollView == self.scrollView {
            makeScrollLog()
        }
    }
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        if scrollView == self.scrollView {
            makeScrollLog()
        }
    }
    
    private func makeScrollLog() {
        let categoryName = getCategoryName(for: currentCategoryId)
        
        inputSubject.send(.logEventDirect(EventParameter.EventLabel.Business.shopCategories, .scroll, "scroll in \(categoryName)"))
    }
}
