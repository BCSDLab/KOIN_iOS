//
//  HomeViewController.swift
//  Koin
//
//  Created by 김나훈 on 1/15/24.
//

import Combine
import UIKit

final class HomeViewControllerB: UIViewController {
    
    // MARK: - Properties
    
    private let viewModel: HomeViewModel
    private let inputSubject: PassthroughSubject<HomeViewModel.Input, Never> = .init()
    private var subscriptions: Set<AnyCancellable> = []
    private let refreshControl = UIRefreshControl()
    private var isSegmentedControlSetupDone = false
    
    // MARK: - UI Components
    
    private let wrapperView: UIView = {
        let view = UIView()
        return view
    }()
    
    private let grayColorView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor.appColor(.neutral50)
        return view
    }()
    
    private let scrollView: UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.contentInsetAdjustmentBehavior = .never
        return scrollView
    }()
    
    private let logoView: LogoView = {
        let logoView = LogoView(frame: .zero)
        return logoView
    }()
    
    private let tabBarView: UIView = {
        let view = UIView()
        view.backgroundColor = .clear
        return view
    }()
    
    private let logoImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage.appImage(asset: .logo)
        return imageView
    }()
    
    private let noticeLabel: UILabel = {
        let label = UILabel()
        label.text = "공지사항"
        label.textColor = UIColor.appColor(.primary500)
        label.font = UIFont.appFont(.pretendardBold, size: 15)
        return label
    }()
    
    private let noticeListCollectionView: NoticeListCollectionView = {
        let flowLayout = UICollectionViewFlowLayout()
        let width = UIScreen.main.bounds.width - 48
        flowLayout.itemSize = CGSize(width: width, height: 175)
        flowLayout.scrollDirection = .horizontal
        flowLayout.minimumLineSpacing = 0
        let collectionView = NoticeListCollectionView(frame: .zero, collectionViewLayout: flowLayout)
        collectionView.decelerationRate = .fast
        return collectionView
    }()
    
    private let noticePageControl: UIPageControl = {
        let pageControl = UIPageControl(frame: .zero)
        pageControl.currentPage = 0
        pageControl.numberOfPages = 4
        pageControl.currentPageIndicatorTintColor = .appColor(.primary400)
        pageControl.pageIndicatorTintColor = .appColor(.neutral300)
        return pageControl
    }()
    
    private let goNoticePageButton: UIButton = {
        let button = UIButton()
        var config = UIButton.Configuration.plain()
        
        let imageConfig = UIImage.SymbolConfiguration(pointSize: 12, weight: .medium, scale: .medium)
        let imageView = UIImage(systemName: SFSymbols.chevronRight.rawValue , withConfiguration: imageConfig)
        var attributedTitle = AttributedString.init("더보기")
        attributedTitle.font = UIFont.appFont(.pretendardRegular, size: 14)
        config.attributedTitle = attributedTitle
        config.image = imageView
        config.imagePadding = 2
        config.imagePlacement = .trailing
        config.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: 0, bottom: 0, trailing: 0)
        button.configuration = config
        button.tintColor = .appColor(.neutral500)
        return button
    }()
    
    private let busLabel: UILabel = {
        let label = UILabel()
        label.text = "버스/교통"
        label.textColor = UIColor.appColor(.primary500)
        label.font = UIFont.appFont(.pretendardBold, size: 15)
        return label
    }()
    
    private let busCollectionView: BusCollectionView = {
        let flowLayout = UICollectionViewFlowLayout()
        let width = UIScreen.main.bounds.width - 120
        flowLayout.itemSize = CGSize(width: width, height: 175)
        flowLayout.scrollDirection = .horizontal
        flowLayout.minimumLineSpacing = 8
        let collectionView = BusCollectionView(frame: .zero, collectionViewLayout: flowLayout)
        collectionView.decelerationRate = .fast
        return collectionView
    }()
    
    private let shopLabel: UILabel = {
        let label = UILabel()
        label.text = "주변상점"
        label.textColor = UIColor.appColor(.primary500)
        label.font = UIFont.appFont(.pretendardBold, size: 15)
        return label
    }()
    
    private let shopListButton = UIButton().then { button in
        var configuration = UIButton.Configuration.plain()
        configuration.image = UIImage.appImage(asset: .smallShop)
        var text = AttributedString("상점 목록")
        text.font = UIFont.appFont(.pretendardMedium, size: 16)
        configuration.attributedTitle = text
        configuration.imagePadding = 8
        configuration.baseBackgroundColor = .systemBackground
        configuration.baseForegroundColor = UIColor.appColor(.neutral600)
        button.configuration = configuration
    }
    
    private let callBenefitButton = UIButton().then { button in
        var configuration = UIButton.Configuration.plain()
        configuration.image = UIImage.appImage(asset: .smallBenefit)
        var text = AttributedString("전화 주문 혜택")
        text.font = UIFont.appFont(.pretendardMedium, size: 16)
        configuration.attributedTitle = text
        configuration.imagePadding = 8
        configuration.baseBackgroundColor = .systemBackground
        configuration.baseForegroundColor = UIColor.appColor(.neutral600)
        button.configuration = configuration
    }
    
    private let menuLabel: UILabel = {
        let label = UILabel()
        label.textColor = UIColor.appColor(.primary500)
        label.font = UIFont.appFont(.pretendardBold, size: 15)
        return label
    }()
    
    private let diningTooltipImageView: CancelableImageView = {
        let imageView = CancelableImageView(frame: .zero)
        imageView.isHidden = true
        return imageView
    }()
    
    private let cornerSegmentControl: UISegmentedControl = {
        let segment = UISegmentedControl()
        segment.setBackgroundImage(UIImage(), for: .normal, barMetrics: .default)
        segment.setDividerImage(UIImage(), forLeftSegmentState: .normal, rightSegmentState: .normal, barMetrics: .default)
        segment.insertSegment(withTitle: "A코너", at: 0, animated: true)
        segment.insertSegment(withTitle: "B코너", at: 1, animated: true)
        segment.insertSegment(withTitle: "C코너", at: 2, animated: true)
        segment.insertSegment(withTitle: "능수관", at: 3, animated: true)
        segment.selectedSegmentIndex = 0
        segment.setTitleTextAttributes([NSAttributedString.Key.foregroundColor: UIColor.appColor(.neutral500), NSAttributedString.Key.font: UIFont.appFont(.pretendardMedium, size: 14)], for: .normal)
        segment.setTitleTextAttributes([NSAttributedString.Key.foregroundColor: UIColor.appColor(.primary500), NSAttributedString.Key.font: UIFont.appFont(.pretendardMedium, size: 14)], for: .selected)
        return segment
    }()
    
    private lazy var underlineView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor.appColor(.primary500)
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private let menuBackgroundView: MenuBackgroundView = {
        let menuBackgroundView = MenuBackgroundView(frame: .zero)
        return menuBackgroundView
    }()
    
    // MARK: - Initialization
    
    init(viewModel: HomeViewModel) {
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
        inputSubject.send(.viewDidLoad)
        inputSubject.send(.getBusInfo(.koreatech, .terminal, .shuttleBus))
        configureView()
        configureTapGesture()
        configureSwipeGestures()
        inputSubject.send(.getNoticeInfo)
        NotificationCenter.default.addObserver(self, selector: #selector(appWillEnterForeground), name: UIApplication.willEnterForegroundNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(appDidEnterBackground), name: UIApplication.didEnterBackgroundNotification, object: nil)
        cornerSegmentControl.addTarget(self, action: #selector(segmentDidChange), for: .valueChanged)
        checkAndShowTooltip()
        shopListButton.addTarget(self, action: #selector(shopSelectButtonTapped), for: .touchUpInside)
        callBenefitButton.addTarget(self, action: #selector(callBenefitButtonTapped), for: .touchUpInside)
        inputSubject.send(.logEvent(EventParameter.EventLabel.ABTest.businessBenefit, .abTest, "혜택O", nil, nil, nil, nil))
        print(KeyChainWorker.shared.read(key: .access) ?? "")
        print(KeyChainWorker.shared.read(key: .refresh) ?? "")
        print("위가 엑세스 아래가 리프레시")
    }
    
    @objc private func appWillEnterForeground() {
        if let centerIndexPath = busCollectionView.centerCellIndex {
            let busItem = busCollectionView.busItems[centerIndexPath.row]
            inputSubject.send(.getBusInfo(busItem.startBusArea , busItem.endBusArea, busItem.busType))
        }
        
        inputSubject.send(.categorySelected(getDiningPlace()))
        inputSubject.send(.getUserScreenAction(Date(), .enterForeground))
    }
    
    @objc private func appDidEnterBackground() {
        inputSubject.send(.getUserScreenAction(Date(), .enterBackground))
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if let centerIndexPath = busCollectionView.centerCellIndex,
           let cell = busCollectionView.cellForItem(at: centerIndexPath) as? BusCollectionViewCell {
            let busItem = busCollectionView.busItems[centerIndexPath.row]
            inputSubject.send(.getBusInfo(busItem.startBusArea, busItem.endBusArea, busItem.busType))
        } else {
            inputSubject.send(.getBusInfo(.koreatech, .koreatech, .shuttleBus))
        }
        inputSubject.send(.getUserScreenAction(Date(), .enterVC))
        inputSubject.send(.categorySelected(getDiningPlace()))
        inputSubject.send(.getUserScreenAction(Date(), .beginEvent, .mainShopBenefit))
        navigationController?.setNavigationBarHidden(true, animated: animated)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        navigationController?.setNavigationBarHidden(false, animated: animated)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        setupSegmentedControlUnderline()
        if !isSegmentedControlSetupDone {
            setupSegmentedControlUnderline()
            isSegmentedControlSetupDone = true
        }
    }
    
    // MARK: - Bind
    
    private func bind() {
        let outputSubject = viewModel.transform(with: inputSubject.eraseToAnyPublisher())
        outputSubject.receive(on: DispatchQueue.main).sink { [weak self] output in
            switch output {
            case let .updateDining(diningItem, diningType, isToday):
                self?.updateDining(item: diningItem, type: diningType, isToday: isToday)
            case let .updateBus(response):
                self?.updateBusTime(response)
            case .moveBusItem:
                self?.scrollToBusItem()
            case .putImage: break
            case let .updateHotArticles(articles):
                self?.updateHotArticles(articles: articles)
            case let .showForceUpdate(version):
                self?.navigateToForceUpdate(version: version)
            }
        }.store(in: &subscriptions)
        
        
        busCollectionView.busRequestPublisher
            .sink { [weak self] data in
                self?.inputSubject.send(.getBusInfo(data.0, data.1, data.2))
                
                self?.inputSubject.send(.logEvent(EventParameter.EventLabel.Campus.mainBusChangeToFrom, .click, data.2.koreanDescription))
            }
            .store(in: &subscriptions)
        
        busCollectionView.busTypePublisher
            .sink { [weak self] busType in
                self?.redirectByBusCardBtn(busType: busType)
            }.store(in: &subscriptions)
        
        logoView.lineButtonPublisher.sink { [weak self] in
            self?.navigateToServiceSelectViewController()
        }.store(in: &subscriptions)
        
        busCollectionView.scrollPublisheer.sink { [weak self] item in
            self?.inputSubject.send(.logEvent(EventParameter.EventLabel.Campus.mainBusScroll, .scroll, item))
        }.store(in: &subscriptions)
        
        diningTooltipImageView.onImageTapped = { [weak self] in
            self?.navigatetoDining()
        }
        
        diningTooltipImageView.onXButtonTapped = { [weak self] in
            self?.diningTooltipImageView.isHidden = true
        }
        noticeListCollectionView.pageDidChangedPublisher.sink { [weak self] page in
            self?.noticePageControl.currentPage = page
        }.store(in: &subscriptions)
        
        noticeListCollectionView.tapNoticeListPublisher.sink { [weak self] noticeId in
            let service = DefaultNoticeService()
            let repository = DefaultNoticeListRepository(service: service)
            let fetchNoticedataUseCase = DefaultFetchNoticeDataUseCase(noticeListRepository: repository)
            let downloadNoticeAttachmentUseCase = DefaultDownloadNoticeAttachmentsUseCase(noticeRepository: repository)
            let fetchHotNoticeArticlesUseCase = DefaultFetchHotNoticeArticlesUseCase(noticeListRepository: repository)
            let logAnalyticsEventUseCase = DefaultLogAnalyticsEventUseCase(repository: GA4AnalyticsRepository(service: GA4AnalyticsService()))
            let viewModel = NoticeDataViewModel(fetchNoticeDataUseCase: fetchNoticedataUseCase, fetchHotNoticeArticlesUseCase: fetchHotNoticeArticlesUseCase, downloadNoticeAttachmentUseCase: downloadNoticeAttachmentUseCase, logAnalyticsEventUseCase: logAnalyticsEventUseCase, noticeId: noticeId)
            let viewController = NoticeDataViewController(viewModel: viewModel)
            self?.navigationController?.pushViewController(viewController, animated: true)
        }.store(in: &subscriptions)
    }

}

extension HomeViewControllerB {
    
    @objc private func tapGoNoticePageButton() {
            let service = DefaultNoticeService()
            let repository = DefaultNoticeListRepository(service: service)
            let fetchArticleListUseCase = DefaultFetchNoticeArticlesUseCase(noticeListRepository: repository)
            let fetchMyKeywordUseCase = DefaultFetchNotificationKeywordUseCase(noticeListRepository: repository)
            let logAnalyticsEventUseCase = DefaultLogAnalyticsEventUseCase(repository: GA4AnalyticsRepository(service: GA4AnalyticsService()))
            let viewModel = NoticeListViewModel(fetchNoticeArticlesUseCase: fetchArticleListUseCase, fetchMyKeywordUseCase: fetchMyKeywordUseCase, logAnalyticsEventUseCase: logAnalyticsEventUseCase)
            let noticeListViewController = NoticeListViewController(viewModel: viewModel)
            navigationController?.pushViewController(noticeListViewController, animated: true)
        }
    
    private func navigateToForceUpdate(version: String) {
        let viewController = ForceUpdateViewController(viewModel: ForceUpdateViewModel(logAnalyticsEventUseCase: DefaultLogAnalyticsEventUseCase(repository: GA4AnalyticsRepository(service: GA4AnalyticsService())), checkVersionUseCase: DefaultCheckVersionUseCase(coreRepository: DefaultCoreRepository(service: DefaultCoreService()))))
        viewController.modalPresentationStyle = .fullScreen
        inputSubject.send(.logEvent(EventParameter.EventLabel.ForceUpdate.forcedUpdatePageView, .pageView, version))
        self.present(viewController, animated: true, completion: nil)
    }
    
    private func checkAndShowTooltip() {
        let hasShownImage = UserDefaults.standard.bool(forKey: "hasShownTooltip")
        
        if !hasShownImage {
                    diningTooltipImageView.setUpImage(image: .appImage(asset: .diningTooltip) ?? UIImage())
            diningTooltipImageView.isHidden = false
            UserDefaults.standard.set(true, forKey: "hasShownTooltip")
        }
    }
    
    @objc private func pageControlDidChange(_ sender: UIPageControl) {
          noticeListCollectionView.pageControlChanged(sender.currentPage)
      }
    
    @objc private func segmentDidChange(_ sender: UISegmentedControl) {
        inputSubject.send(.categorySelected(getDiningPlace()))
        
        let underlineFinalXPosition = (sender.bounds.width / CGFloat(sender.numberOfSegments)) *  CGFloat(sender.selectedSegmentIndex)
        UIView.animate(
            withDuration: 0.2,
            animations: { [weak self] in
                self?.underlineView.frame.origin.x = underlineFinalXPosition
            }
        )
        
        inputSubject.send(.logEvent(EventParameter.EventLabel.Campus.mainMenuCorner, .click, getDiningPlace().rawValue))
    }
    
    private func redirectByBusCardBtn(busType: BusType) {
        switch busType {
        case .shuttleBus:
            if let url = URL(string: "https://koreatech.unibus.kr"),
               UIApplication.shared.canOpenURL(url) {
                UIApplication.shared.open(url, options: [:], completionHandler: nil)
            }
        case .expressBus:
            let movingPage = BusDetailViewController(selectedPage: (2, .expressBus))
            movingPage.title = "버스/교통"
            self.navigationController?.pushViewController(movingPage, animated: true)
        default:
            let movingPage = BusDetailViewController(selectedPage: (2, .cityBus))
            movingPage.title = "버스/교통"
            self.navigationController?.pushViewController(movingPage, animated: true)
        }
    }
    
    private func navigateToServiceSelectViewController() {
        let serviceSelectViewController = ServiceSelectViewController(viewModel: ServiceSelectViewModel(fetchUserDataUseCase: DefaultFetchUserDataUseCase(userRepository: DefaultUserRepository(service: DefaultUserService())), logAnalyticsEventUseCase: DefaultLogAnalyticsEventUseCase(repository: GA4AnalyticsRepository(service: GA4AnalyticsService()))))
        navigationController?.pushViewController(serviceSelectViewController, animated: true)
    }
    
    private func scrollToBusItem() {
        let initialIndexPath = IndexPath(item: 4, section: 0)
        busCollectionView.scrollToItem(at: initialIndexPath, at: .centeredHorizontally, animated: false)
        inputSubject.send(.getBusInfo(.koreatech, .terminal, .shuttleBus))
    }
    
    private func updateBusTime(_ data: BusCardInformation) {
        busCollectionView.updateText(data: data)
    }
    
    private func configureTapGesture() {
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(menuViewTapped))
        menuBackgroundView.addGestureRecognizer(tapGesture)
        
        let tapGesture2 = UITapGestureRecognizer(target: self, action: #selector(busViewTapped))
        busCollectionView.addGestureRecognizer(tapGesture2)
        
    }
    
    private func configureSwipeGestures() {
        let swipeLeftGesture = UISwipeGestureRecognizer(target: self, action: #selector(handleSwipe(_:)))
        swipeLeftGesture.direction = .left
        menuBackgroundView.addGestureRecognizer(swipeLeftGesture)
        let swipeRightGesture = UISwipeGestureRecognizer(target: self, action: #selector(handleSwipe(_:)))
        swipeRightGesture.direction = .right
        menuBackgroundView.addGestureRecognizer(swipeRightGesture)
    }
    
    @objc private func handleSwipe(_ gesture: UISwipeGestureRecognizer) {
        let currentSegmentIndex = cornerSegmentControl.selectedSegmentIndex
        if gesture.direction == .left {
            if currentSegmentIndex < cornerSegmentControl.numberOfSegments - 1 {
                cornerSegmentControl.selectedSegmentIndex = currentSegmentIndex + 1
            }
        } else if gesture.direction == .right {
            if currentSegmentIndex > 0 {
                cornerSegmentControl.selectedSegmentIndex = currentSegmentIndex - 1
            }
        }
        segmentDidChange(cornerSegmentControl)
    }
    
    @objc private func menuViewTapped() {
        navigatetoDining()
    }
    
    private func navigatetoDining() {
        let diningService = DefaultDiningService()
        let shareService = KakaoShareService()
        let diningRepository = DefaultDiningRepository(diningService: diningService, shareService: shareService)
        let notiRepository = DefaultNotiRepository(service: DefaultNotiService())
        let fetchDiningListUseCase = DefaultFetchDiningListUseCase(diningRepository: diningRepository)
        let diningLikeUseCase = DefaultDiningLikeUseCase(diningRepository: diningRepository)
        let logAnalyticsEventUseCase = DefaultLogAnalyticsEventUseCase(repository: GA4AnalyticsRepository(service: GA4AnalyticsService()))
        let dateProvider = DefaultDateProvider()
        let shareMenuListUseCase = DefaultShareMenuListUseCase(diningRepository: diningRepository)
        let changeNotiUseCase = DefaultChangeNotiUseCase(notiRepository: notiRepository)
        let changeNotiDetailUseCase = DefaultChangeNotiDetailUseCase(notiRepository: notiRepository)
        let fetchNotiListUseCase = DefaultFetchNotiListUseCase(notiRepository: notiRepository)
        let viewModel = DiningViewModel(fetchDiningListUseCase: fetchDiningListUseCase, logAnalyticsEventUseCase: logAnalyticsEventUseCase, dateProvder: dateProvider, shareMenuListUseCase: shareMenuListUseCase, diningLikeUseCase: diningLikeUseCase, changeNotiUseCase: changeNotiUseCase, fetchNotiListUsecase: fetchNotiListUseCase, changeNotiDetailUseCase: changeNotiDetailUseCase)
        let diningViewController = DiningViewController(viewModel: viewModel)
        diningViewController.title = "식단"
        navigationController?.pushViewController(diningViewController, animated: true)
        
        inputSubject.send(.logEvent(EventParameter.EventLabel.Campus.mainMenuMoveDetailView, .click, "\(menuLabel.text ?? "")", nil, nil, nil, nil))
    }
    private func updateHotArticles(articles: [NoticeArticleDTO]) {
          noticeListCollectionView.updateNoticeList(articles)
      }
    @objc private func busViewTapped() {
        let busViewController = BusDetailViewController(selectedPage: (0, .shuttleBus))
        busViewController.title = "버스/교통"
        navigationController?.pushViewController(busViewController, animated: true)
        
        inputSubject.send(.logEvent(EventParameter.EventLabel.Campus.mainBus, .click, "버스"))
    }
    
    private func updateDining(item: DiningItem?, type: DiningType, isToday: Bool) {
        menuBackgroundView.updateDining(item, type)
        if isToday {
            self.menuLabel.text = "오늘 식단"
        }
        else {
            self.menuLabel.text = "내일 식단"
        }
    }
    
    @objc private func shopSelectButtonTapped() {
        navigateToShop(section: .shopList)
    }
    
    @objc private func callBenefitButtonTapped() {
        inputSubject.send(.getUserScreenAction(Date(), .endEvent, .mainShopBenefit))
        inputSubject.send(.logEvent(EventParameter.EventLabel.Business.mainShopBenefit, .click, "전화주문혜택", "메인", "benefit", .endEvent, .mainShopBenefit))
        navigateToShop(section: .callBenefit)
    }
    
    private func navigateToShop(section: ShopViewControllerB.Section) {
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
        let viewController: UIViewController
        switch section {
        case .shopList: viewController = ShopViewControllerA(viewModel: viewModel)
        case .callBenefit: viewController = ShopViewControllerB(viewModel: viewModel, section: section)
        }
        navigationController?.pushViewController(viewController, animated: true)
        
        let category = MakeParamsForLog().makeValueForLogAboutStoreId(id: 0)
        inputSubject.send(.getUserScreenAction(Date(), .leaveVC, .mainShopCategories))
        switch section {
        case .shopList:
            inputSubject.send(.logEvent(EventParameter.EventLabel.Business.mainShopCategories, .click, category, "메인", category, .leaveVC, .mainShopCategories))
        case .callBenefit: break
            // TODO: 로깅
        }
    }
    
    @objc private func refresh() {
        if let centerIndexPath = busCollectionView.centerCellIndex,
           let cell = busCollectionView.cellForItem(at: centerIndexPath) as? BusCollectionViewCell {
            let busItem = busCollectionView.busItems[centerIndexPath.row]
            inputSubject.send(.getBusInfo(busItem.startBusArea , busItem.endBusArea, busItem.busType))
        }
        
        inputSubject.send(.categorySelected(getDiningPlace()))
        
        refreshControl.endRefreshing()
    }
    
}

extension HomeViewControllerB {
    
    private func getDiningPlace() -> DiningPlace {
        switch cornerSegmentControl.selectedSegmentIndex {
        case 0: return .cornerA
        case 1: return .cornerB
        case 2: return .cornerC
        default: return .special
        }
    }
}


extension HomeViewControllerB {
    
    private func setUpNavigationBar() {
        self.navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: self, action: nil)
    }
    
    private func setUpLayOuts() {
        
        [wrapperView, logoView].forEach {
            view.addSubview($0)
        }
        wrapperView.addSubview(scrollView)
        [noticeLabel, noticeListCollectionView, noticePageControl, goNoticePageButton, busLabel, diningTooltipImageView, busCollectionView, shopLabel, menuLabel, menuBackgroundView, tabBarView, grayColorView, shopListButton, callBenefitButton].forEach {
            scrollView.addSubview($0)
        }
        
        [cornerSegmentControl].forEach {
            tabBarView.addSubview($0)
        }
    }
    
    private func setUpConstraints() {
        wrapperView.snp.makeConstraints { make in
            make.top.equalTo(logoView.snp.bottom)
            make.leading.trailing.bottom.equalToSuperview()
        }
        logoView.snp.makeConstraints { make in
            make.top.equalTo(view.snp.top)
            make.width.equalTo(view.snp.width)
            make.height.equalTo(119)
            make.centerX.equalTo(view.snp.centerX)
        }
        scrollView.snp.makeConstraints { make in
            make.top.equalTo(wrapperView.snp.top)
            make.leading.equalTo(wrapperView.snp.leading)
            make.trailing.equalTo(wrapperView.snp.trailing)
            make.bottom.equalTo(wrapperView.snp.bottom)
        }
        noticeLabel.snp.makeConstraints { make in
                 make.top.equalToSuperview().offset(24)
                 make.leading.equalToSuperview().offset(24)
                 make.height.equalTo(29)
             }
             noticeListCollectionView.snp.makeConstraints { make in
                 make.top.equalTo(noticeLabel.snp.bottom).offset(8)
                 make.leading.equalToSuperview().offset(24)
                 make.trailing.equalToSuperview().inset(24)
                 make.height.equalTo(95)
             }
             noticePageControl.snp.makeConstraints { make in
                 make.top.equalTo(noticeListCollectionView.snp.bottom).offset(12)
                 make.centerX.equalToSuperview()
             }
             goNoticePageButton.snp.makeConstraints { make in
                 make.top.equalTo(noticeLabel).offset(3)
                 make.trailing.equalToSuperview().inset(24)
                 make.height.equalTo(22)
             }
        busLabel.snp.makeConstraints { make in
            make.top.equalTo(noticePageControl.snp.bottom).offset(12)
            make.height.equalTo(22)
            make.leading.equalTo(scrollView.snp.leading).offset(20)
            make.trailing.equalTo(scrollView.snp.trailing)
        }
        busCollectionView.snp.makeConstraints { make in
            make.top.equalTo(busLabel.snp.bottom).offset(11)
            make.width.equalTo(scrollView.snp.width)
            make.height.equalTo(185)
            make.leading.equalTo(scrollView.snp.leading)
            make.trailing.equalTo(scrollView.snp.trailing)
        }
        shopLabel.snp.makeConstraints { make in
            make.top.equalTo(busCollectionView.snp.bottom).offset(40)
            make.height.equalTo(22)
            make.leading.equalTo(scrollView.snp.leading).offset(20)
            make.trailing.equalTo(scrollView.snp.trailing)
        }
        shopListButton.snp.makeConstraints { make in
            make.top.equalTo(shopLabel.snp.bottom).offset(16)
            make.leading.equalTo(view.snp.leading).offset(24)
            make.trailing.equalTo(view.snp.centerX).offset(-5)
            make.height.equalTo(64)
        }
        callBenefitButton.snp.makeConstraints { make in
            make.top.equalTo(shopLabel.snp.bottom).offset(16)
            make.leading.equalTo(view.snp.centerX).offset(5)
            make.trailing.equalTo(view.snp.trailing).offset(-24)
            make.height.equalTo(64)
        }
        menuLabel.snp.makeConstraints { make in
            make.height.equalTo(22)
            make.top.equalTo(callBenefitButton.snp.bottom).offset(30)
            make.leading.equalTo(scrollView.snp.leading).offset(20)
        }
        diningTooltipImageView.snp.makeConstraints { make in
            make.centerY.equalTo(menuLabel.snp.centerY)
            make.leading.equalTo(menuLabel.snp.trailing).offset(8)
            make.width.equalTo(176)
            make.height.equalTo(36)
        }
        menuBackgroundView.snp.makeConstraints { make in
            make.top.equalTo(cornerSegmentControl.snp.bottom)
            make.height.equalTo(233)
            make.leading.equalTo(scrollView.snp.leading)
            make.trailing.equalTo(scrollView.snp.trailing)
            make.bottom.equalTo(scrollView.snp.bottom).offset(-11)
        }
        tabBarView.snp.makeConstraints {
            $0.top.equalTo(menuLabel.snp.bottom).offset(16)
            $0.leading.equalToSuperview().offset(24)
            $0.height.equalTo(45)
            $0.width.equalTo(264)
        }
        cornerSegmentControl.snp.makeConstraints {
            $0.top.leading.trailing.equalToSuperview()
            $0.height.equalTo(43)
        }
    }
    private func setUpRoundedCorners() {
        logoView.layer.cornerRadius = 20
        logoView.layer.maskedCorners = [.layerMaxXMaxYCorner, .layerMinXMaxYCorner]
        logoView.clipsToBounds = true
    }
    
    private func setUpShadow() {
        logoView.layer.masksToBounds = false
        logoView.layer.shadowColor = UIColor.black.cgColor
        logoView.layer.shadowOpacity = 0.5
        logoView.layer.shadowOffset = CGSize(width: 0, height: 2)
        logoView.layer.shadowRadius = 4
    }
    
    private func setUpButtons() {
        [shopListButton, callBenefitButton].forEach {
            $0.layer.cornerRadius = 8
            $0.layer.shadowColor = UIColor.gray.cgColor
            $0.layer.shadowOpacity = 0.2
            $0.layer.shadowOffset = CGSize.zero
            $0.layer.shadowRadius = 6
            $0.backgroundColor = .systemBackground
           }
    }
    
    private func configureView() {
        setUpNavigationBar()
        setUpLayOuts()
        setUpConstraints()
        setUpShadow()
        setUpButtons()
        setUpRoundedCorners()
        scrollView.alwaysBounceVertical = true
        refreshControl.addTarget(self, action: #selector(refresh), for: .valueChanged)
        noticePageControl.addTarget(self, action: #selector(pageControlDidChange), for: .valueChanged)
              goNoticePageButton.addTarget(self, action: #selector(tapGoNoticePageButton), for: .touchUpInside)
        scrollView.refreshControl = refreshControl
        self.view.backgroundColor = .systemBackground
    }
    
    private func setupSegmentedControlUnderline() {
        
        let segmentControl = cornerSegmentControl
        let numberOfSegments = CGFloat(segmentControl.numberOfSegments)
        let underlineWidth = segmentControl.bounds.size.width / numberOfSegments
        let underlineHeight: CGFloat = 2
        let underlineXPosition = underlineWidth * CGFloat(segmentControl.selectedSegmentIndex)
        let underlineYPosition = segmentControl.bounds.size.height - underlineHeight
        
        underlineView.frame = CGRect(x: underlineXPosition, y: underlineYPosition, width: underlineWidth, height: underlineHeight)
        
        tabBarView.addSubview(underlineView)
    }
}


