//
//  ShopViewController.swift
//  Koin
//
//  Created by 김나훈 on 3/12/24.
//

import Combine
import UIKit

final class ShopViewControllerB: UIViewController {
    
    // MARK: - Properties
    
    enum Section: String {
        case shopList = "주변 상점"
        case callBenefit = "전화 주문 혜택"
    }
    
    private let viewModel: ShopViewModel
    private let inputSubject: PassthroughSubject<ShopViewModel.Input, Never> = .init()
    private let section: Section
    private var subscriptions: Set<AnyCancellable> = []
    private var scrollDirection: ScrollLog = .scrollToDown
    
    // MARK: - UI Components
    
    private let scrollView: UIScrollView = {
        let scrollView = UIScrollView()
        return scrollView
    }()
    
    private let callBenefitCollectionView: CallBenefitCollectionView = {
        let flowLayout = UICollectionViewFlowLayout()
        let collectionView = CallBenefitCollectionView(frame: .zero, collectionViewLayout: flowLayout)
        return collectionView
    }()
    
    private let grayView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor.appColor(.neutral100)
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
    
    init(viewModel: ShopViewModel, section: Section) {
        self.viewModel = viewModel
        self.section = section
        super.init(nibName: nil, bundle: nil)
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Life Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.title = "전화 주문 혜택"
        bind()
        configureView()
        shopCollectionView.setHeaderVisibility(isHidden: true)
        inputSubject.send(.viewDidLoadB)
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
        inputSubject.send(.getUserScreenAction(Date(), .beginEvent, .benefitShopCategories))
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
            guard let strongSelf = self else { return }
            switch output {
            case let .changeFilteredShops(shops, id):
                break
            case let .putImage(response):
                break
            case let .updateEventShops(eventShops):
                self?.updateEventShops(eventShops)
            case let .updateSeletecButtonColor(standard):
                self?.shopCollectionView.updateSeletecButtonColor(standard)
            case let .updateShopBenefits(response):
                self?.callBenefitCollectionView.updateBenefits(benefits: response)
                self?.callBenefitCollectionView.snp.updateConstraints({ make in
                    make.height.equalTo(strongSelf.callBenefitCollectionView.calculateDynamicHeight())
                })
            case let .updateBeneficialShops(response):
                self?.updateFilteredShops(response)
            }
        }.store(in: &subscriptions)
        
        shopCollectionView.cellTapPublisher.sink { [weak self] shopId, shopName in
          
            self?.navigateToShopDataViewController(shopId: shopId, shopName: shopName, categoryId: 0)
            self?.inputSubject.send(.getUserScreenAction(Date(), .leaveVC, .shopClick))
            self?.inputSubject.send(.logEvent(EventParameter.EventLabel.Business.shopClick, .click, shopName, nil, shopName, .leaveVC, .shopClick))
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
        
        callBenefitCollectionView.filterPublisher.sink { [weak self] selectedId, previousTitle, currentTitle in
            self?.inputSubject.send(.getUserScreenAction(Date(), .endEvent, .benefitShopCategories))
            self?.inputSubject.send(.logEvent(EventParameter.EventLabel.Business.benefitShopCategories, .click, currentTitle, previousTitle, currentTitle, .endEvent, .benefitShopCategories))
            self?.inputSubject.send(.getUserScreenAction(Date(), .beginEvent, .benefitShopCategories))
            self?.viewModel.shopCallBenefitFilterName = currentTitle
            self?.inputSubject.send(.getBeneficialShops(selectedId))
        }.store(in: &subscriptions)
    }
}

extension ShopViewControllerB {
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

extension ShopViewControllerB: UIScrollViewDelegate {
    
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

extension ShopViewControllerB {
    
    private func navigateToShopDataViewController(shopId: Int, shopName: String, categoryId: Int? = nil) {
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
        let shopDataViewModel = ShopDataViewModel(fetchShopDataUseCase: fetchShopDataUseCase, fetchShopMenuListUseCase: fetchShopMenuListUseCase, fetchShopEventListUseCase: fetchShopEventListUseCase, fetchShopReviewListUseCase: fetchShopReviewListUsecase, fetchMyReviewUseCase: fetchMyReviewUseCase, deleteReviewUseCase: deleteReviewUseCase, logAnalyticsEventUseCase: logAnalyticsEventUseCase, getUserScreenTimeUseCase: getUserScreenTimeUseCase, shopId: shopId, shopName: shopName, categoryId: categoryId)
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
    
    @objc private func textFieldDidChange(_ textField: UITextField) {
        guard let text = textField.text else { return }
        inputSubject.send(.searchTextChanged(text))
    }
    
    @objc private func textFieldClicked(_ textField: UITextField) {
        self.inputSubject.send(.logEvent(EventParameter.EventLabel.Business.shopCategoriesSearch, EventParameter.EventCategory.click, "search in \(MakeParamsForLog().makeValueForLogAboutStoreId(id: viewModel.selectedId))"))
    }
}
extension ShopViewControllerB {
    
    private func setUpLayOuts() {
        view.addSubview(scrollView)
        [callBenefitCollectionView, grayView, eventShopCollectionView, shopCollectionView, eventIndexLabel, callBenefitCollectionView].forEach {
            scrollView.addSubview($0)
        }
    }
    
    private func setUpConstraints() {
        
        scrollView.snp.makeConstraints { make in
            make.leading.trailing.bottom.equalToSuperview()
            make.top.equalTo(self.view.safeAreaLayoutGuide.snp.top)
        }
        
        callBenefitCollectionView.snp.makeConstraints { make in
            make.top.equalTo(scrollView.snp.top).offset(19)
            make.leading.equalTo(scrollView.snp.leading).offset(5)
            make.trailing.equalTo(scrollView.snp.trailing).offset(-5)
            make.height.equalTo(150)
        }
        
        grayView.snp.makeConstraints { make in
            make.top.equalTo(callBenefitCollectionView.snp.bottom).offset(20)
            make.leading.equalTo(scrollView.snp.leading)
            make.width.equalTo(view.snp.width)
            make.height.equalTo(12)
            make.trailing.equalTo(scrollView.snp.trailing)
        }
        
        eventShopCollectionView.snp.makeConstraints { make in
            make.top.equalTo(grayView.snp.bottom).offset(20)
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
            make.top.equalTo(grayView.snp.bottom).offset(14)
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

