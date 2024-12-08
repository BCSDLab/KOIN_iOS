//
//  HomeViewController.swift
//  Koin
//
//  Created by 김나훈 on 1/15/24.
//

import Combine
import UIKit

final class HomeViewController: UIViewController {
    
    // MARK: - Properties
    
    private let viewModel: HomeViewModel
    private let inputSubject: PassthroughSubject<HomeViewModel.Input, Never> = .init()
    private var subscriptions: Set<AnyCancellable> = []
    private let refreshControl = UIRefreshControl()
    private var isSegmentedControlSetupDone = false
    private var scrollDirection: ScrollLog = .scrollToDown
    
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
    
    private let busView = BusView()
    
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
    
    private let goNoticePageButton = UIButton()
    
    private let goDiningPageButton = UIButton()
    
    private let busLabel: UILabel = {
        let label = UILabel()
        label.text = "버스"
        label.textColor = UIColor.appColor(.primary500)
        label.font = UIFont.appFont(.pretendardBold, size: 15)
        return label
    }()
    
    private let busQrCodeButton: UIButton = {
        var configuration = UIButton.Configuration.plain()
        configuration.image = UIImage.appImage(asset: .qrCode)
        configuration.attributedTitle = AttributedString("셔틀 탑승권", attributes: AttributeContainer([.font: UIFont.appFont(.pretendardRegular, size: 14), .foregroundColor: UIColor.appColor(.neutral600)]))
        configuration.imagePadding = 3
        configuration.imagePlacement = .leading
        let button = UIButton()
        button.configuration = configuration
        return button
    }()
    
    private let shopLabel: UILabel = {
        let label = UILabel()
        label.text = "주변상점"
        label.textColor = UIColor.appColor(.primary500)
        label.font = UIFont.appFont(.pretendardBold, size: 15)
        return label
    }()
    
    private let categoryCollectionView: CategoryCollectionView = {
        let flowLayout = UICollectionViewFlowLayout()
        let collectionView = CategoryCollectionView(frame: .zero, collectionViewLayout: flowLayout)
        return collectionView
    }()
    
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
        configureView()
        configureSwipeGestures()
        NotificationCenter.default.addObserver(self, selector: #selector(appWillEnterForeground), name: UIApplication.willEnterForegroundNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(appDidEnterBackground), name: UIApplication.didEnterBackgroundNotification, object: nil)
        cornerSegmentControl.addTarget(self, action: #selector(segmentDidChange), for: .valueChanged)
        checkAndShowTooltip()
        print(KeyChainWorker.shared.read(key: .access) ?? "")
        
        print("위가 엑세스 아래가 리프레시")
        inputSubject.send(.logEvent(EventParameter.EventLabel.ABTest.businessBenefit, .abTestBenefit, "혜택X", nil, nil, nil, nil))
        inputSubject.send(.getAbTestResult("c_main_dining_v1"))
        inputSubject.send(.getAbTestResult("c_keyword_ banner_v1"))
        scrollView.delegate = self
    }
    
    @objc private func appWillEnterForeground() {
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
        inputSubject.send(.getUserScreenAction(Date(), .enterVC))
        inputSubject.send(.categorySelected(getDiningPlace()))
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
            case let .putImage(response):
                self?.putImage(data: response)
            case let .updateNoticeBanners(hotNoticeArticlesInfo, keywordNoticePhrases):
                self?.updateHotArticles(articles: hotNoticeArticlesInfo, phrases: keywordNoticePhrases)
            case let .showForceUpdate(version):
                self?.navigateToForceUpdate(version: version)
            case let .setAbTestResult(abTestResult):
                self?.setAbTestResult(result: abTestResult)
            }
        }.store(in: &subscriptions)
        
        logoView.lineButtonPublisher.sink { [weak self] in
            self?.navigateToServiceSelectViewController()
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
        
        
        categoryCollectionView.cellTapPublisher.sink { [weak self] id in
            self?.didTapCell(at: id)
        }.store(in: &subscriptions)
        
        noticeListCollectionView.tapNoticeListPublisher.sink { [weak self] noticeId, noticeTitle in
            self?.inputSubject.send(.logEvent(EventParameter.EventLabel.Campus.popularNoticeBanner, .click, noticeTitle))
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
        
        noticeListCollectionView.moveKeywordManagePagePublisher.sink { [weak self] bannerIndex in
            let bannerLogValue = ["자취방 양도", "안내글", "근로", "해외탐방"]
            let logValue = bannerLogValue[bannerIndex]
            self?.inputSubject.send(.logEvent(EventParameter.EventLabel.Campus.toManageKeyword, .click, logValue))
            let service = DefaultNoticeService()
            let repository = DefaultNoticeListRepository(service: service)
            let notiRepository = DefaultNotiRepository(service: DefaultNotiService())
            let viewModel = ManageNoticeKeywordViewModel(addNotificationKeywordUseCase: DefaultAddNotificationKeywordUseCase(noticeListRepository: repository), deleteNotificationKeywordUseCase: DefaultDeleteNotificationKeywordUseCase(noticeListRepository: repository), fetchNotificationKeywordUseCase: DefaultFetchNotificationKeywordUseCase(noticeListRepository: repository), fetchRecommendedKeywordUseCase: DefaultFetchRecommendedKeywordUseCase(noticeListRepository: repository), changeNotiUseCase: DefaultChangeNotiUseCase(notiRepository: notiRepository), fetchNotiListUseCase: DefaultFetchNotiListUseCase(notiRepository: notiRepository), logAnalyticsEventUseCase: DefaultLogAnalyticsEventUseCase(repository: GA4AnalyticsRepository(service: GA4AnalyticsService())))
            let viewController = ManageNoticeKeywordViewController(viewModel: viewModel)
            self?.navigationController?.pushViewController(viewController, animated: true)
        }.store(in: &subscriptions)
        
        busView.moveBusSearchPublisher.sink {
            //추후 버스 노선 검색 화면 이동
        }.store(in: &subscriptions)
        
        busView.moveBusTimetablePublisher.sink {
            //추후 버스 시간표 화면 이동
        }.store(in: &subscriptions)
    }
}

extension HomeViewController {
    
    @objc private func tapBusQrCode() {
        if let url = URL(string: "https://koreatech.unibus.kr/#!/qrcode") {
            UIApplication.shared.open(url, options: [:], completionHandler: nil)
        }
    }
    
    @objc private func tapGoOtherPageButton(sender: UIButton) {
        if sender == goNoticePageButton {
           navigateToNoticeList()
            inputSubject.send(.logEvent(EventParameter.EventLabel.Campus.appMainNoticeDetail, .click, "더보기"))
        }
        else if sender == goDiningPageButton {
            navigatetoDining()
        }
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
            print("express")
        default:
            print("시내버스")
        }
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
    
    @objc private func busViewTapped() {
        let repository = DefaultBusRepository(service: DefaultBusService())
        let viewModel = BusTimetableViewModel(fetchExpressTimetableUseCase: DefaultFetchExpressTimetableUseCase(busRepository: repository), getExpressFiltersUseCase: DefaultGetExpressFilterUseCase(), getCityFiltersUseCase: DefaultGetCityFiltersUseCase(), fetchCityTimetableUseCase: DefaultFetchCityBusTimetableUseCase(busRepository: repository), getShuttleFilterUseCase: DefaultGetShuttleBusFilterUseCase(), fetchShuttleRoutesUseCase: DefaultFetchShuttleBusRoutesUseCase(busRepository: repository))
        let viewController = BusTimetableViewController(viewModel: viewModel)
        navigationController?.pushViewController(viewController, animated: true)
        
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
    
    private func updateHotArticles(articles: [NoticeArticleDTO], phrases: ((String, String), Int)?) {
        noticeListCollectionView.updateNoticeList(articles, phrases)
    }
    
    private func putImage(data: ShopCategoryDTO) {
        var categories = data.shopCategories
        let newCategory = ShopCategory(id: -1, name: "혜택", imageURL: "https://stage-static.koreatech.in/upload/SHOPS/2024/12/12/fc8da75a-a3ca-48ed-8a16-023394f8315a/shopBenefit.svg")
           categories.insert(newCategory, at: 0)
        categoryCollectionView.updateCategories(categories)
    }
    
    private func setAbTestResult(result: AssignAbTestResponse) {
        if result.variableName == .mainDiningOriginal {
            goDiningPageButton.isHidden = true
            inputSubject.send(.logEvent(EventParameter.EventLabel.ABTest.campusDining, .abTestDining, "더보기X"))
        }
        else if result.variableName == .mainDiningNew {
            goDiningPageButton.isHidden = false
            inputSubject.send(.logEvent(EventParameter.EventLabel.ABTest.campusDining, .abTestDining, "더보기O"))
        }
        else if result.variableName == .bannerNew {
            noticePageControl.numberOfPages = 5
            inputSubject.send(.logEvent(EventParameter.EventLabel.ABTest.campusNotice, .abTestKeyword, "진입점O"))
            inputSubject.send(.getNoticeBanner(Date()))
        }
        else {
            noticePageControl.numberOfPages = 4
            inputSubject.send(.logEvent(EventParameter.EventLabel.ABTest.campusNotice, .abTestKeyword, "진입점X"))
            inputSubject.send(.getNoticeBanner(nil))
        }
    }
    
    func didTapCell(at id: Int) {
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
            selectedId: id
        )
        
        if id >= 0 {
            let shopViewController = ShopViewControllerA(viewModel: viewModel)
            shopViewController.title = "주변상점"
            navigationController?.pushViewController(shopViewController, animated: true)
            
            let category = MakeParamsForLog().makeValueForLogAboutStoreId(id: id)
            inputSubject.send(.getUserScreenAction(Date(), .leaveVC, .mainShopCategories))
            inputSubject.send(.logEvent(EventParameter.EventLabel.Business.mainShopCategories, .click, category, "메인", category, .leaveVC, .mainShopCategories))
        } else if id == -1 {
            let shopViewController = ShopViewControllerB(viewModel: viewModel, section: .callBenefit)
            inputSubject.send(.logEvent(EventParameter.EventLabel.Business.mainShopBenefit, .click, "전화주문혜택", "메인", "benefit", .leaveVC, .mainShopCategories))
            navigationController?.pushViewController(shopViewController, animated: true)
        }
    }
    
    @objc private func refresh() {
        inputSubject.send(.categorySelected(getDiningPlace()))
        
        refreshControl.endRefreshing()
    }
    
    // navigate 함수
    private func navigateToNoticeList() {
        let service = DefaultNoticeService()
        let repository = DefaultNoticeListRepository(service: service)
        let fetchArticleListUseCase = DefaultFetchNoticeArticlesUseCase(noticeListRepository: repository)
        let fetchMyKeywordUseCase = DefaultFetchNotificationKeywordUseCase(noticeListRepository: repository)
        let logAnalyticsEventUseCase = DefaultLogAnalyticsEventUseCase(repository: GA4AnalyticsRepository(service: GA4AnalyticsService()))
        let viewModel = NoticeListViewModel(fetchNoticeArticlesUseCase: fetchArticleListUseCase, fetchMyKeywordUseCase: fetchMyKeywordUseCase, logAnalyticsEventUseCase: logAnalyticsEventUseCase)
        let noticeListViewController = NoticeListViewController(viewModel: viewModel)
        navigationController?.pushViewController(noticeListViewController, animated: true)
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
        let viewModel = DiningViewModel(fetchDiningListUseCase: fetchDiningListUseCase, logAnalyticsEventUseCase: logAnalyticsEventUseCase, dateProvder: dateProvider, shareMenuListUseCase: shareMenuListUseCase, diningLikeUseCase: diningLikeUseCase, changeNotiUseCase: changeNotiUseCase, fetchNotiListUsecase: fetchNotiListUseCase, changeNotiDetailUseCase: changeNotiDetailUseCase, assignAbTestUseCase: DefaultAssignAbTestUseCase(abTestRepository: DefaultAbTestRepository(service: DefaultAbTestService())))
        let diningViewController = DiningViewController(viewModel: viewModel)
        diningViewController.title = "식단"
        navigationController?.pushViewController(diningViewController, animated: true)
        inputSubject.send(.logEvent(EventParameter.EventLabel.Campus.mainMenuMoveDetailView, .click, "\(menuLabel.text ?? "")", nil, nil, nil, nil))
    }
    
    private func navigateToServiceSelectViewController() {
        let serviceSelectViewController = ServiceSelectViewController(viewModel: ServiceSelectViewModel(fetchUserDataUseCase: DefaultFetchUserDataUseCase(userRepository: DefaultUserRepository(service: DefaultUserService())), logAnalyticsEventUseCase: DefaultLogAnalyticsEventUseCase(repository: GA4AnalyticsRepository(service: GA4AnalyticsService()))))
        navigationController?.pushViewController(serviceSelectViewController, animated: true)
    }
    
    private func navigateToForceUpdate(version: String) {
        let viewController = ForceUpdateViewController(viewModel: ForceUpdateViewModel(logAnalyticsEventUseCase: DefaultLogAnalyticsEventUseCase(repository: GA4AnalyticsRepository(service: GA4AnalyticsService())), checkVersionUseCase: DefaultCheckVersionUseCase(coreRepository: DefaultCoreRepository(service: DefaultCoreService()))))
        viewController.modalPresentationStyle = .fullScreen
        inputSubject.send(.logEvent(EventParameter.EventLabel.ForceUpdate.forcedUpdatePageView, .pageView, version))
        self.present(viewController, animated: true, completion: nil)
    }
}

extension HomeViewController {
    
    private func getDiningPlace() -> DiningPlace {
        switch cornerSegmentControl.selectedSegmentIndex {
        case 0: return .cornerA
        case 1: return .cornerB
        case 2: return .cornerC
        default: return .special
        }
    }
}

extension HomeViewController: UIScrollViewDelegate {
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
        let contentOffsetY = scrollView.contentOffset.y
        let screenHeight = scrollView.frame.height
        if scrollDirection == .scrollToDown && contentOffsetY > screenHeight * 0.25 && scrollDirection != .scrollChecked {
            scrollDirection = .scrollChecked
            inputSubject.send(.logEvent(EventParameter.EventLabel.Campus.mainScroll, .scroll, "70%"))
        }
    }
}

extension HomeViewController {
    
    private func setUpNavigationBar() {
        self.navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: self, action: nil)
    }
    
    private func setUpButtons() {
        [goNoticePageButton, goDiningPageButton].forEach {
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
            $0.configuration = config
            $0.tintColor = .appColor(.neutral500)
        }
    }
    
    private func setUpLayOuts() {
        
        [wrapperView, logoView].forEach {
            view.addSubview($0)
        }
        wrapperView.addSubview(scrollView)
        [noticeLabel, noticeListCollectionView, noticePageControl, goNoticePageButton, busLabel, diningTooltipImageView, shopLabel, categoryCollectionView, menuLabel, menuBackgroundView, tabBarView, grayColorView, goDiningPageButton, busView, busQrCodeButton].forEach {
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
        goDiningPageButton.snp.makeConstraints { make in
            make.top.equalTo(menuLabel).offset(3)
            make.trailing.equalToSuperview().inset(24)
            make.height.equalTo(22)
        }
        busLabel.snp.makeConstraints { make in
            make.top.equalTo(noticePageControl.snp.bottom).offset(12)
            make.height.equalTo(22)
            make.leading.equalTo(scrollView.snp.leading).offset(20)
            make.trailing.equalTo(scrollView.snp.trailing)
        }
        busQrCodeButton.snp.makeConstraints { make in
            make.trailing.equalToSuperview().inset(24)
            make.centerY.equalTo(busLabel)
            make.height.equalTo(22)
        }
        busView.snp.makeConstraints { make in
            make.top.equalTo(busLabel.snp.bottom).offset(16)
            make.leading.equalTo(scrollView)
            make.trailing.equalTo(scrollView)
            make.height.equalTo(65)
            make.width.equalTo(scrollView.snp.width)
        }
        shopLabel.snp.makeConstraints { make in
            make.top.equalTo(busView.snp.bottom).offset(40)
            make.height.equalTo(22)
            make.leading.equalTo(scrollView.snp.leading).offset(20)
            make.trailing.equalTo(scrollView.snp.trailing)
        }
        categoryCollectionView.snp.makeConstraints { make in
            make.top.equalTo(shopLabel.snp.bottom).offset(11)
            make.leading.equalTo(scrollView.snp.leading)
            make.trailing.equalTo(scrollView.snp.trailing)
            make.height.equalTo(146)
        }
        menuLabel.snp.makeConstraints { make in
            make.height.equalTo(22)
            make.top.equalTo(categoryCollectionView.snp.bottom).offset(24)
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
    
    private func configureView() {
        setUpNavigationBar()
        setUpButtons()
        setUpLayOuts()
        setUpConstraints()
        setUpShadow()
        setUpRoundedCorners()
        scrollView.alwaysBounceVertical = true
        refreshControl.addTarget(self, action: #selector(refresh), for: .valueChanged)
        noticePageControl.addTarget(self, action: #selector(pageControlDidChange), for: .valueChanged)
        goNoticePageButton.addTarget(self, action: #selector(tapGoOtherPageButton), for: .touchUpInside)
        goDiningPageButton.addTarget(self, action: #selector(tapGoOtherPageButton), for: .touchUpInside)
        scrollView.refreshControl = refreshControl
        busQrCodeButton.addTarget(self, action: #selector(tapBusQrCode), for: .touchUpInside)
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
