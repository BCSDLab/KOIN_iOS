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
    
    private let viewModel: ShopViewModel
    private let inputSubject: PassthroughSubject<ShopViewModel.Input, Never> = .init()
    private var subscriptions: Set<AnyCancellable> = []
    private var scrollDirection: ScrollLog = .scrollToDown
    
    // MARK: - UI Components
    
    private let scrollView = UIScrollView()
    private let contentView = UIView()
    
    private let categoryCollectionView = CategoryCollectionView(frame: .zero, collectionViewLayout: UICollectionViewFlowLayout())
    
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
        let selectedBackgroundColor = UIColor.appColor(.new500)
        let unselectedBackgroundColor = UIColor.white
        let selectedTitleColor = UIColor.white
        let unselectedTitleColor = UIColor.appColor(.neutral400)
        let filterImage = UIImage.appImage(asset: .filterIcon1)?.withRenderingMode(.alwaysTemplate)

        var config = UIButton.Configuration.plain()
        config.image = filterImage
        config.baseForegroundColor = unselectedTitleColor
        config.title = "영업중"
        config.attributedTitle = AttributedString("영업중", attributes: AttributeContainer([
            .font: UIFont.appFont(.pretendardBold, size: 14),
            .foregroundColor: unselectedTitleColor
        ]))
        config.imagePadding = 6
        config.imagePlacement = .leading
        config.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: 12, bottom: 0, trailing: 12)

        config.background.backgroundColor = unselectedBackgroundColor
        config.background.cornerRadius = 17
        config.background.strokeWidth = 0

        config.background.backgroundColorTransformer = UIConfigurationColorTransformer { _ in
            unselectedBackgroundColor
        }

        button.configuration = config

        button.layer.shadowColor = UIColor.black.cgColor
        button.layer.shadowOffset = CGSize(width: 0, height: 2)
        button.layer.shadowRadius = 4
        button.layer.shadowOpacity = 0.04
        button.layer.cornerRadius = 17
        button.layer.masksToBounds = false

        button.addAction(UIAction { [weak button] _ in
            guard let button = button else { return }
            button.isSelected.toggle()
            let color = button.isSelected ? selectedTitleColor : unselectedTitleColor

            var config = button.configuration
            config?.baseForegroundColor = color
            config?.attributedTitle = AttributedString("영업중", attributes: AttributeContainer([
                .font: UIFont.appFont(.pretendardBold, size: 14),
                .foregroundColor: color
            ]))
            config?.background.backgroundColor = button.isSelected ? selectedBackgroundColor : unselectedBackgroundColor

            config?.background.backgroundColorTransformer = UIConfigurationColorTransformer { _ in
                return button.isSelected ? selectedBackgroundColor : unselectedBackgroundColor
            }
            button.configuration = config
        }, for: .touchUpInside)
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
        $0.textColor = UIColor.appColor(.neutral0)
        $0.backgroundColor = UIColor.appColor(.neutral800).withAlphaComponent(0.6)
        $0.layer.cornerRadius = 5
        $0.layer.masksToBounds = true
        $0.textAlignment = .center
        $0.isHidden = true
    }

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
        bind()
        configureView()
        inputSubject.send(.viewDidLoad)
        hideKeyboardWhenTappedAround()
        searchTextField.addTarget(self, action: #selector(textFieldDidChange(_:)), for: .editingChanged)
        searchTextField.delegate = self
        searchTextField.addTarget(self, action: #selector(textFieldClicked), for: .editingDidBegin)
        categoryCollectionView.enableFooter(true)
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(dismissCollectionView))
        tapGesture.cancelsTouchesInView = false // 텍스트 필드 터치 방해하지 않도록 설정
        view.addGestureRecognizer(tapGesture)
        
        NotificationCenter.default.addObserver(self, selector: #selector(appDidEnterBackground), name: UIApplication.didEnterBackgroundNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(appWillEnterForeground), name: UIApplication.willEnterForegroundNotification, object: nil)
        self.scrollView.delegate = self
    }
    
    @objc private func dismissCollectionView(_ sender: UITapGestureRecognizer) {
        // 터치된 위치가 searchTextField 외부인지 확인하여 컬렉션 뷰를 숨기고 키보드를 내림
        if !searchTextField.frame.contains(sender.location(in: view)) {
            searchedShopCollectionView.isHidden = true
            dimView.isHidden = true
            searchTextField.resignFirstResponder() // 키보드 내리기
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        eventShopCollectionView.stopAutoScroll()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        configureNavigationBar(style: .fill)
        eventShopCollectionView.startAutoScroll()
        inputSubject.send(.getUserScreenAction(Date(), .enterVC, nil))
        inputSubject.send(.getUserScreenAction(Date(), .beginEvent, .shopCategories))
        inputSubject.send(.getUserScreenAction(Date(), .beginEvent, .shopClick))
    }
    
    @objc private func appDidEnterBackground() {
        inputSubject.send(.getUserScreenAction(Date(), .enterBackground, nil))
    }
    
    @objc private func appWillEnterForeground() {
        inputSubject.send(.getUserScreenAction(Date(), .enterForeground, nil))
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    // MARK: - Bind
    
    private func bind() {
        let outputSubject = viewModel.transform(with: inputSubject.eraseToAnyPublisher())
        outputSubject.receive(on: DispatchQueue.main).sink { [weak self] output in
            switch output {
            case let .changeFilteredShops(shops, id):
                self?.updateFilteredShops(shops)
                self?.updateFilteredCategory(id)
            case let .putImage(response):
                self?.putImage(data: response)
            case let .updateEventShops(eventShops):
                self?.updateEventShops(eventShops)
//            case let .updateSeletecButtonColor(standard):
//                self?.shopCollectionView.updateSeletecButtonColor(standard)
            case .updateShopBenefits:
                break
            case .updateBeneficialShops(_):
                break
            case let .showSearchedResult(result):
                self?.searchedShopCollectionView.updateShop(keywords: result)
            case let .navigateToShopData(shopId, shopName, categoryId):
                self?.navigateToShopDataViewController(shopId: shopId, shopName: shopName, categoryId: categoryId)
            }
        }.store(in: &subscriptions)
        
        shopCollectionView.cellTapPublisher.sink { [weak self] shopId, shopName in
            let categoryId = self?.categoryCollectionView.selectedCategoryPublisher.value
            self?.viewModel.assignShopAbTest(shopId: shopId, shopName: shopName, categoryId: self?.categoryCollectionView.selectedCategoryPublisher.value ?? 0)
            self?.inputSubject.send(.getUserScreenAction(Date(), .endEvent, .shopClick))
            self?.inputSubject.send(.logEvent(EventParameter.EventLabel.Business.shopClick, .click, shopName, nil, shopName, .endEvent, .shopClick))
        }.store(in: &subscriptions)
        
        categoryCollectionView.cellTapPublisher.sink { [weak self] categoryId in
            let category = MakeParamsForLog().makeValueForLogAboutStoreId(id: categoryId)
            self?.inputSubject.send(.getUserScreenAction(Date(), .endEvent, .shopCategories))
            self?.inputSubject.send(.logEvent(EventParameter.EventLabel.Business.shopCategories, .click, category, nil, category, .endEvent, .shopCategories))
            self?.inputSubject.send(.getUserScreenAction(Date(), .beginEvent, .shopCategories))
            self?.inputSubject.send(.getUserScreenAction(Date(), .beginEvent, .shopClick))
            self?.searchTextField.text = ""
            self?.inputSubject.send(.changeCategory(categoryId))
        }.store(in: &subscriptions)
        
        eventShopCollectionView.cellTapPublisher.sink { [weak self] shopId, shopName in
            self?.navigateToShopDataViewController(shopId: shopId, shopName: shopName)
            self?.inputSubject.send(.logEvent(EventParameter.EventLabel.Business.shopCategoriesEvent, EventParameter.EventCategory.click, shopName))
        }.store(in: &subscriptions)
        
        eventShopCollectionView.scrollPublisher.sink { [weak self] index in
            self?.eventIndexLabel.text = index
        }.store(in: &subscriptions)
        
        shopCollectionView.shopSortStandardPublisher.sink { [weak self] standard in
            self?.inputSubject.send(.changeSortStandard(standard))
        }.store(in: &subscriptions)
        
        shopCollectionView.shopFilterTogglePublisher.sink { [weak self] toggleType in
            self?.filterToggleLogEvent(toggleType: toggleType)
        }.store(in: &subscriptions)
        
        searchedShopCollectionView.selectedShopIdPublisher.sink { [weak self] shopId in
            self?.navigateToShopDataViewController(shopId: shopId, shopName: "")
        }.store(in: &subscriptions)
        
        categoryCollectionView.publisher.sink { [weak self] in
            let shopService = DefaultShopService()
            let shopRepository = DefaultShopRepository(service: shopService)
            
            let fetchShopListUseCase = DefaultFetchShopListUseCase(shopRepository: shopRepository)
            let fetchEventListUseCase = DefaultFetchEventListUseCase(shopRepository: shopRepository)
            let fetchShopCategoryListUseCase = DefaultFetchShopCategoryListUseCase(shopRepository: shopRepository)
            let fetchShopBenefitUseCase = DefaultFetchShopBenefitUseCase(shopRepository: shopRepository)
            let fetchBeneficialShopUseCase = DefaultFetchBeneficialShopUseCase(shopRepository: shopRepository)
            let searchShopUseCase = DefaultSearchShopUseCase(shopRepository: shopRepository)
            let logAnalyticsEventUseCase = DefaultLogAnalyticsEventUseCase(repository: GA4AnalyticsRepository(service: GA4AnalyticsService()))
            let getUserScreenTimeUseCase = DefaultGetUserScreenTimeUseCase()
            
            let viewModel = ShopViewModel(
                fetchShopListUseCase: fetchShopListUseCase,
                fetchEventListUseCase: fetchEventListUseCase,
                fetchShopCategoryListUseCase: fetchShopCategoryListUseCase, searchShopUseCase: searchShopUseCase,
                logAnalyticsEventUseCase: logAnalyticsEventUseCase, getUserScreenTimeUseCase: getUserScreenTimeUseCase,
                fetchShopBenefitUseCase: fetchShopBenefitUseCase,
                fetchBeneficialShopUseCase: fetchBeneficialShopUseCase,
                selectedId: 0
            )
            
            self?.inputSubject.send(.logEvent(EventParameter.EventLabel.Business.shopCategoriesBenefit, .click, "혜택이 있는 상점 모아보기"))

        }.store(in: &subscriptions)
    }
}

extension ShopViewController {
    @objc private func textFieldDidChange(_ textField: UITextField) {
        guard let text = textField.text else { return }
        searchedShopCollectionView.isHidden = false
        dimView.isHidden = false
        inputSubject.send(.searchTextChanged(text))
    }
        
    private func filterToggleLogEvent(toggleType: Int) {
        var value = ""
        switch toggleType {
        case 0:
            value = "check_review"
        case 1:
            value = "check_star"
        case 2:
            value = "check_open"
        default:
            value = "check_delivery"
        }
        
        inputSubject.send(.logEvent(EventParameter.EventLabel.Business.shopCan, .click, value))
    }
    
    private func updateEventShops(_ eventShops: [EventDTO]) {
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
            eventIndexLabel.text = "< 1/\(eventShops.count) >"
        }
    }
}

extension ShopViewController: UIScrollViewDelegate {
    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        let velocity = scrollView.panGestureRecognizer.velocity(in: scrollView.superview)
        if velocity.y > 0 {
            scrollDirection = .scrollToTop
        }
        else {
            if scrollDirection != .scrollChecked {
                scrollDirection = .scrollToDown
            }
        }
    }
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        let contentOffsetY = self.scrollView.contentOffset.y
        let screenHeight = self.scrollView.frame.height
        if scrollDirection == .scrollToDown && contentOffsetY > screenHeight * 0.7 && scrollDirection != .scrollChecked {
            inputSubject.send(.logEvent(EventParameter.EventLabel.Business.shopCategories, EventParameter.EventCategory.scroll, "scroll in \(MakeParamsForLog().makeValueForLogAboutStoreId(id: viewModel.selectedId))"))
            scrollDirection = .scrollChecked
        }
    }
}

extension ShopViewController {
    private func navigateToShopDataViewController(shopId: Int, shopName: String, categoryId: Int? = nil) {
        let shopService = DefaultShopService()
        let shopRepository = DefaultShopRepository(service: shopService)
        let fetchShopDataUseCase = DefaultFetchShopDataUseCase(shopRepository: shopRepository)
        let fetchShopMenuListUseCase = DefaultFetchShopMenuListUseCase(shopRepository: shopRepository)
        let fetchShopEventListUseCase = DefaultFetchShopEventListUseCase(shopRepository: shopRepository)
        let fetchShopReviewListUsecase = DefaultFetchShopReviewListUseCase(shopRepository: shopRepository)
        let postCallNotificationUseCase = DefaultPostCallNotificationUseCase(shopRepository: shopRepository)
        let fetchMyReviewUseCase = DefaultFetchMyReviewUseCase(shopRepository: shopRepository)
        let deleteReviewUseCase = DefaultDeleteReviewUseCase(shopRepository: shopRepository)
        let logAnalyticsEventUseCase = DefaultLogAnalyticsEventUseCase(repository: GA4AnalyticsRepository(service: GA4AnalyticsService()))
        let getUserScreenTimeUseCase = DefaultGetUserScreenTimeUseCase()
        let shopDataViewModel = ShopDataViewModel(fetchShopDataUseCase: fetchShopDataUseCase, fetchShopMenuListUseCase: fetchShopMenuListUseCase, fetchShopEventListUseCase: fetchShopEventListUseCase, fetchShopReviewListUseCase: fetchShopReviewListUsecase, fetchMyReviewUseCase: fetchMyReviewUseCase, deleteReviewUseCase: deleteReviewUseCase, logAnalyticsEventUseCase: logAnalyticsEventUseCase, getUserScreenTimeUseCase: getUserScreenTimeUseCase, postCallNotificationUseCase: postCallNotificationUseCase, shopId: shopId, shopName: shopName, categoryId: categoryId, enterByShopCallBenefit: false)
        
        let shopDataViewController: UIViewController
        if viewModel.userAssignType == .callNumber {
            shopDataViewController = ShopDataViewControllerA(viewModel: shopDataViewModel)
        } else {
            shopDataViewController = ShopDataViewControllerB(viewModel: shopDataViewModel)
        }
        shopDataViewController.title = "주변상점"
        navigationController?.pushViewController(shopDataViewController, animated: true)
    }
    
    private func updateFilteredShops(_ shops: [Shop]) {
        shopCollectionView.updateShop(shops)
        
        shopCollectionView.snp.updateConstraints { make in
            make.height.equalTo(shopCollectionView.calculateDynamicHeight())
        }
    }
    
    private func updateFilteredCategory(_ id: Int) {
        categoryCollectionView.updateCategory(id)
    }
    
    private func putImage(data: ShopCategoryDTO) {
        categoryCollectionView.updateCategories(data.shopCategories)
    }
    
    @objc private func textFieldClicked(_ textField: UITextField) {
        self.inputSubject.send(.logEvent(EventParameter.EventLabel.Business.shopCategoriesSearch, EventParameter.EventCategory.click, "search in \(MakeParamsForLog().makeValueForLogAboutStoreId(id: viewModel.selectedId))"))
    }
}

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
            $0.edges.equalTo(view.safeAreaLayoutGuide)
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
            $0.height.equalTo(200)
        }

        dimView.snp.makeConstraints {
            $0.top.equalTo(searchedShopCollectionView.snp.bottom)
            $0.leading.trailing.equalTo(searchedShopCollectionView)
            $0.bottom.equalToSuperview()
        }

        categoryCollectionView.snp.makeConstraints {
            $0.top.equalTo(searchTextField.snp.bottom).offset(12)
            $0.leading.trailing.equalToSuperview()
            $0.height.equalTo(193)
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

