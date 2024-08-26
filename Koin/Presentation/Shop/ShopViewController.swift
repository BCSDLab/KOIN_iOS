//
//  ShopViewController.swift
//  Koin
//
//  Created by 김나훈 on 3/12/24.
//

import Combine
import UIKit

final class ShopViewController: UIViewController {
    
    // MARK: - Properties
    
    private let viewModel: ShopViewModel
    private let inputSubject: PassthroughSubject<ShopViewModel.Input, Never> = .init()
    private var subscriptions: Set<AnyCancellable> = []
    private var scrollDirection: ScrollLog = .scrollToDown
    
    // MARK: - UI Components
    
    private let scrollView: UIScrollView = {
        let scrollView = UIScrollView()
        return scrollView
    }()
    
    private let categoryCollectionView: CategoryCollectionView = {
        let flowLayout = UICollectionViewFlowLayout()
        let collectionView = CategoryCollectionView(frame: .zero, collectionViewLayout: flowLayout)
        return collectionView
    }()
    
    private let shopGuideView: ShopGuideView = {
        let view = ShopGuideView(frame: .zero)
        return view
    }()
    
    private let eventShopCollectionView: EventShopCollectionView = {
        let flowLayout = UICollectionViewFlowLayout()
        flowLayout.itemSize = CGSize(width: UIScreen.main.bounds.width - 40, height: 80)
        flowLayout.scrollDirection = .horizontal
        let collectionView = EventShopCollectionView(frame: .zero, collectionViewLayout: flowLayout)
        collectionView.isHidden = true
        return collectionView
    }()
    
    private let eventIndexLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.appFont(.pretendardRegular, size: 10)
        label.textColor = UIColor.appColor(.neutral0)
        label.backgroundColor = UIColor.appColor(.neutral800).withAlphaComponent(0.6)
        label.layer.cornerRadius = 5
        label.layer.masksToBounds = true
        label.textAlignment = .center
        label.isHidden = true
        return label
    }()
    
    private let searchTextField: UITextField = {
        let textField = UITextField()
        textField.placeholder = "검색어를 입력해주세요."
        textField.font = UIFont.appFont(.pretendardRegular, size: 14)
        textField.tintColor = UIColor.appColor(.neutral500)
        textField.backgroundColor = UIColor.appColor(.neutral100)
        let paddingView: UIView = UIView(frame: CGRect(x: 0, y: 0, width: 16, height: 20))
        textField.leftView = paddingView
        textField.leftViewMode = .always
        let imageView = UIImageView(image: UIImage.appImage(asset: .search))
        imageView.contentMode = .scaleAspectFit
        let iconContainerView = UIView(frame: CGRect(x: 0, y: 0, width: 24 + 12, height: 24))
        imageView.frame = CGRect(x: 0, y: 0, width: 24, height: 24)
        iconContainerView.addSubview(imageView)
        textField.rightView = iconContainerView
        textField.rightViewMode = .always
        return textField
    }()
    
    private lazy var shopCollectionView: ShopInfoCollectionView = {
        let flowLayout = UICollectionViewFlowLayout()
        flowLayout.scrollDirection = .vertical
        let screenWidth = UIScreen.main.bounds.width
        let cellWidth = screenWidth - 40
        let collectionView = ShopInfoCollectionView(frame: .zero, collectionViewLayout: flowLayout)
        flowLayout.itemSize = CGSize(width: cellWidth, height: 72)
        flowLayout.minimumLineSpacing = 8
        collectionView.isScrollEnabled = false
        return collectionView
    }()
    
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
        bind()
        configureView()
        inputSubject.send(.viewDidLoad)
        searchTextField.addTarget(self, action: #selector(textFieldDidChange(_:)), for: .editingChanged)
        hideKeyboardWhenTappedAround()
        searchTextField.delegate = self
        searchTextField.addTarget(self, action: #selector(textFieldClicked), for: .editingDidBegin)
        NotificationCenter.default.addObserver(self, selector: #selector(appDidEnterBackground), name: UIApplication.didEnterBackgroundNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(appWillEnterForeground), name: UIApplication.willEnterForegroundNotification, object: nil)
        self.scrollView.delegate = self
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        eventShopCollectionView.stopAutoScroll()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        eventShopCollectionView.startAutoScroll()
        inputSubject.send(.getUserScreenAction(Date(), .enterVC, nil))
        inputSubject.send(.getUserScreenAction(Date(), .beginEvent, .shopCategories))
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
            case let .updateSeletecButtonColor(standard):
                self?.shopCollectionView.updateSeletecButtonColor(standard)
            }
        }.store(in: &subscriptions)
        
        shopCollectionView.cellTapPublisher.sink { [weak self] shopId, shopName in
            let categoryId = self?.categoryCollectionView.selectedCategoryPublisher.value
            self?.navigateToShopDataViewController(shopId: shopId, categoryId: categoryId)
            self?.inputSubject.send(.getUserScreenAction(Date(), .leaveVC, .shopClick))
            self?.inputSubject.send(.logEvent(EventParameter.EventLabel.Business.shopClick, .click, shopName, shopName, .leaveVC, .shopClick))
        }.store(in: &subscriptions)
        
        categoryCollectionView.cellTapPublisher.sink { [weak self] categoryId in
            let category = MakeParamsForLog().makeValueForLogAboutStoreId(id: categoryId)
            self?.inputSubject.send(.getUserScreenAction(Date(), .endEvent, .shopCategories))
            self?.inputSubject.send(.logEvent(EventParameter.EventLabel.Business.shopCategories, .click, category, category, .endEvent, .shopCategories))
            self?.inputSubject.send(.getUserScreenAction(Date(), .beginEvent, .shopCategories))
            self?.searchTextField.text = ""
            self?.inputSubject.send(.changeCategory(categoryId))
        }.store(in: &subscriptions)
        
        eventShopCollectionView.cellTapPublisher.sink { [weak self] shopId in
            self?.navigateToShopDataViewController(shopId: shopId)
        }.store(in: &subscriptions)
        
        eventShopCollectionView.cellTapTitlePublisher.sink { [weak self] shopName in
            self?.inputSubject.send(.logEvent(EventParameter.EventLabel.Business.shopCategoriesEvent, EventParameter.EventCategory.click, shopName))
        }.store(in: &subscriptions)
        
        eventShopCollectionView.scrollPublisher.sink { [weak self] index in
            self?.eventIndexLabel.text = index
        }.store(in: &subscriptions)
        
        shopCollectionView.shopSortStandardPublisher.sink { [weak self] standard in
            self?.inputSubject.send(.changeSortStandard(standard))
        }.store(in: &subscriptions)
    }
}

extension ShopViewController {
    
    private func updateEventShops(_ eventShops: [EventDTO]) {

        eventShopCollectionView.isHidden = eventShops.isEmpty
        eventIndexLabel.isHidden = eventShops.isEmpty
        if !eventShops.isEmpty {
            shopCollectionView.snp.remakeConstraints { make in
                make.top.equalTo(eventShopCollectionView.snp.bottom).offset(14)
                make.leading.equalTo(scrollView.snp.leading).offset(16)
                make.trailing.equalTo(scrollView.snp.trailing).offset(-16)
                make.height.equalTo(shopCollectionView.calculateDynamicHeight())
                make.bottom.equalTo(scrollView.snp.bottom)
            }
            eventShopCollectionView.setEventShops(eventShops)
            eventIndexLabel.text = "1/\(eventShops.count)"
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
    
    private func navigateToShopDataViewController(shopId: Int, categoryId: Int? = nil) {
        let shopService = DefaultShopService()
        let shopRepository = DefaultShopRepository(service: shopService)
        let fetchShopDataUseCase = DefaultFetchShopDataUseCase(shopRepository: shopRepository)
        let fetchShopMenuListUseCase = DefaultFetchShopMenuListUseCase(shopRepository: shopRepository)
        let fetchShopEventListUseCase = DefaultFetchShopEventListUseCase(shopRepository: shopRepository)
        let fetchShopReviewListUsecase = DefaultFetchShopReviewListUseCase(shopRepository: shopRepository)
        let fetchMyReviewUseCase = DefaultFetchMyReviewUseCase(shopRepository: shopRepository)
        let deleteReviewUseCase = DefaultDeleteReviewUseCase(shopRepository: shopRepository)
        let logAnalyticsEventUseCase = DefaultLogAnalyticsEventUseCase(repository: GA4AnalyticsRepository(service: GA4AnalyticsService()))
        let getUserScreenTimeUseCase = DefaultGetUserScreenTimeUseCase()
        let shopDataViewModel = ShopDataViewModel(fetchShopDataUseCase: fetchShopDataUseCase, fetchShopMenuListUseCase: fetchShopMenuListUseCase, fetchShopEventListUseCase: fetchShopEventListUseCase, fetchShopReviewListUseCase: fetchShopReviewListUsecase, fetchMyReviewUseCase: fetchMyReviewUseCase, deleteReviewUseCase: deleteReviewUseCase, logAnalyticsEventUseCase: logAnalyticsEventUseCase, getUserScreenTimeUseCase: getUserScreenTimeUseCase, shopId: shopId, categoryId: categoryId)
        let shopDataViewController = ShopDataViewController(viewModel: shopDataViewModel)
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

    @objc private func textFieldDidChange(_ textField: UITextField) {
        guard let text = textField.text else { return }
        inputSubject.send(.searchTextChanged(text))
    }
    
    @objc private func textFieldClicked(_ textField: UITextField) {
        self.inputSubject.send(.logEvent(EventParameter.EventLabel.Business.shopCategoriesSearch, EventParameter.EventCategory.click, "search in \(MakeParamsForLog().makeValueForLogAboutStoreId(id: viewModel.selectedId))"))
    }
}
extension ShopViewController {
    
    private func setUpLayOuts() {
        view.addSubview(scrollView)
        [categoryCollectionView, shopGuideView, eventShopCollectionView, searchTextField, shopCollectionView, eventIndexLabel].forEach {
            scrollView.addSubview($0)
        }
    }
    
    private func setUpConstraints() {
        
        scrollView.snp.makeConstraints { make in
            make.leading.trailing.bottom.equalToSuperview()
            make.top.equalTo(self.view.safeAreaLayoutGuide.snp.top)
        }
        
        searchTextField.snp.makeConstraints { make in
            make.top.equalTo(scrollView.snp.top).offset(16)
            make.leading.equalTo(scrollView.snp.leading).offset(16)
            make.trailing.equalTo(scrollView.snp.trailing).offset(-16)
            make.height.equalTo(44)
        }
        
        categoryCollectionView.snp.makeConstraints { make in
            make.top.equalTo(searchTextField.snp.bottom).offset(19)
            make.leading.equalTo(scrollView.snp.leading).offset(23)
            make.trailing.equalTo(scrollView.snp.trailing).offset(-23)
            make.height.equalTo(180)
        }
        
        shopGuideView.snp.makeConstraints { make in
            make.top.equalTo(categoryCollectionView.snp.bottom).offset(10)
            make.leading.equalTo(scrollView.snp.leading)
            make.width.equalTo(view.snp.width)
            make.height.equalTo(32)
            make.trailing.equalTo(scrollView.snp.trailing)
        }
        
        eventShopCollectionView.snp.makeConstraints { make in
            make.top.equalTo(shopGuideView.snp.bottom).offset(12)
            make.leading.equalTo(scrollView.snp.leading).offset(20)
            make.trailing.equalTo(scrollView.snp.trailing).offset(-20)
            make.height.equalTo(63)
        }
        
        eventIndexLabel.snp.makeConstraints { make in
            make.bottom.equalTo(eventShopCollectionView.snp.bottom).offset(-7)
            make.trailing.equalTo(eventShopCollectionView.snp.trailing).offset(-6)
            make.width.equalTo(37)
            make.height.equalTo(14)
        }
        
        shopCollectionView.snp.makeConstraints { make in
            make.top.equalTo(shopGuideView.snp.bottom).offset(14)
            make.leading.equalTo(scrollView.snp.leading).offset(20)
            make.trailing.equalTo(scrollView.snp.trailing).offset(-20)
            make.height.equalTo(1)
            make.bottom.equalTo(scrollView.snp.bottom)
        }
        
    }
    
    private func configureView() {
        setUpLayOuts()
        setUpConstraints()
        self.view.backgroundColor = .systemBackground
    }
}

