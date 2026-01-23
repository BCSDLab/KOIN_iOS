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
    
    private let wrapperView = UIView()
    
    private let grayColorView = UIView().then {
        $0.backgroundColor = UIColor.appColor(.neutral50)
    }
    
    private let scrollView = UIScrollView().then {
        $0.contentInsetAdjustmentBehavior = .never
    }
    
    private let logoView = LogoView(frame: .zero).then { _ in
    }
    
    private let tabBarView = UIView().then {
        $0.backgroundColor = .clear
    }
    
    private let logoImageView = UIImageView().then {
        $0.image = UIImage.appImage(asset: .logo)
    }
    
    private let noticeLabel = UILabel().then {
        $0.text = "게시판"
        $0.textColor = UIColor.appColor(.primary500)
        $0.font = UIFont.appFont(.pretendardBold, size: 15)
    }
    
    private let busView = BusView()
    
    private let clubView = ClubView()
    
    private let noticeListCollectionView = NoticeListCollectionView(frame: .zero, collectionViewLayout:  UICollectionViewFlowLayout().then{
        $0.itemSize = CGSize(width: UIScreen.main.bounds.width - 48, height: 175)
        $0.scrollDirection = .horizontal
        $0.minimumLineSpacing = 0
    }).then {
        $0.decelerationRate = .fast
    }
    
    private let noticePageControl = UIPageControl(frame: .zero).then {
        $0.currentPage = 0
        $0.currentPageIndicatorTintColor = .appColor(.primary400)
        $0.pageIndicatorTintColor = .appColor(.neutral300)
    }
    
    private let goNoticePageButton = UIButton()
    
    private let goDiningPageButton = UIButton()
    
    private let busLabel = UILabel().then {
        $0.text = "버스"
        $0.textColor = UIColor.appColor(.primary500)
        $0.font = UIFont.appFont(.pretendardBold, size: 15)
    }
    
    private let busQrCodeButton = UIButton().then {
        var configuration = UIButton.Configuration.plain()
        configuration.image = UIImage.appImage(asset: .qrCode)
        configuration.attributedTitle = AttributedString("셔틀 탑승권", attributes: AttributeContainer([.font: UIFont.appFont(.pretendardRegular, size: 14), .foregroundColor: UIColor.appColor(.neutral600)]))
        configuration.imagePadding = 3
        configuration.imagePlacement = .leading
        $0.configuration = configuration
    }
    
    private let lostItemListView = LostItemListView()
    
    private let orderLabel = UILabel().then {
        $0.text = "주변 상점"
        $0.textColor = UIColor.appColor(.primary500)
        $0.font = UIFont.appFont(.pretendardBold, size: 15)
    }
    
    private let categoryCollectionView = CategoryCollectionView(frame: .zero, collectionViewLayout: UICollectionViewFlowLayout().then{ _ in})
    
    private let menuLabel = UILabel().then {
        $0.textColor = UIColor.appColor(.primary500)
        $0.font = UIFont.appFont(.pretendardBold, size: 15)
    }
    
    private let diningTooltipImageView = CancelableImageView(frame: .zero).then {
        $0.isHidden = true
    }
    
    private let cornerSegmentControl = UISegmentedControl().then {
        $0.setBackgroundImage(UIImage(), for: .normal, barMetrics: .default)
        $0.setDividerImage(UIImage(), forLeftSegmentState: .normal, rightSegmentState: .normal, barMetrics: .default)
        $0.insertSegment(withTitle: "A코너", at: 0, animated: true)
        $0.insertSegment(withTitle: "B코너", at: 1, animated: true)
        $0.insertSegment(withTitle: "C코너", at: 2, animated: true)
        $0.insertSegment(withTitle: "능수관", at: 3, animated: true)
        $0.selectedSegmentIndex = 0
        $0.setTitleTextAttributes([NSAttributedString.Key.foregroundColor: UIColor.appColor(.neutral500), NSAttributedString.Key.font: UIFont.appFont(.pretendardMedium, size: 14)], for: .normal)
        $0.setTitleTextAttributes([NSAttributedString.Key.foregroundColor: UIColor.appColor(.primary500), NSAttributedString.Key.font: UIFont.appFont(.pretendardMedium, size: 14)], for: .selected)
    }
    
    private lazy var underlineView = UIView().then {
        $0.backgroundColor = UIColor.appColor(.primary500)
        $0.translatesAutoresizingMaskIntoConstraints = false
    }
    
    private let menuBackgroundView = MenuBackgroundView(frame: .zero)
    
    private lazy var bannerViewControllerA = BannerViewControllerA(viewModel: viewModel)
    
    private lazy var bannerViewControllerB = BannerViewControllerB(viewModel: viewModel)
    
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
        print(KeychainWorker.shared.read(key: .access))
        print(KeychainWorker.shared.read(key: .fcm))
        print(KeychainWorker.shared.read(key: .accessHistoryId))
        inputSubject.send(.viewDidLoad)
        inputSubject.send(.getNoticeBanner(Date()))
        inputSubject.send(.getLostItemStat)
        configureView()
        configureSwipeGestures()
        configureTapGesture()
        NotificationCenter.default.addObserver(self, selector: #selector(appWillEnterForeground), name: UIApplication.willEnterForegroundNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(appDidEnterBackground), name: UIApplication.didEnterBackgroundNotification, object: nil)
        cornerSegmentControl.addTarget(self, action: #selector(segmentDidChange), for: .valueChanged)
        checkAndShowTooltip()
        checkAndShowBanner()
        inputSubject.send(.logEvent(EventParameter.EventLabel.AbTest.businessBenefit, .abTestBenefit, "혜택X", nil, nil, nil, nil))
        inputSubject.send(.getAbTestResult("c_main_dining_v1"))
        inputSubject.send(.getClubAbTest("a_main_club_ui"))
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
        inputSubject.send(.getUserScreenAction(Date(), .beginEvent, .mainShopCategories))
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
            case .showForceModal:
                self?.navigationController?.setViewControllers([ForceModifyUserViewController()], animated: true)
            case .updateBanner(let banner, let abTestResult):
                self?.showBanner(banner: banner, abTestResult: abTestResult)
            case .setHotClub(let hotClub):
                self?.clubView.setupHotClub(club: hotClub)
            case .setClubCategories(let response):
                self?.clubView.setupClubCategories(categories: response.clubCategories)
            case .updateLostItem(let lostLostStats):
                self?.lostItemListView.configure(lostItemStats: lostLostStats)
            }
        }.store(in: &subscriptions)
        
        clubView.clubCategoryPublisher.sink { [weak self] id in
            self?.navigationController?.pushViewController(ClubWebViewController(parameter: "/clubs?categoryId=\(id)"), animated: true)
        }.store(in: &subscriptions)
        
        clubView.clubListButtonPublisher.sink { [weak self] in
            self?.navigationController?.pushViewController(ClubWebViewController(parameter: "/clubs"), animated: true)
        }.store(in: &subscriptions)
        
        clubView.hotClubButtonPublisher.sink { [weak self] id in
            self?.navigationController?.pushViewController(ClubWebViewController(parameter: "/clubs"), animated: true)
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
        
        categoryCollectionView.cellTapPublisher.sink { [weak self] shopName in
            guard let self = self else { return }
            
            self.inputSubject.send(.getUserScreenAction(Date(), .endEvent, .mainShopCategories))

            let categoryName = self.viewModel.getCategoryName(for: shopName) ?? "알 수 없음"
                        
            self.inputSubject.send(.logEvent(EventParameter.EventLabel.Business.mainShopCategories, .click, categoryName, "메인", nil, nil, .mainShopCategories))
            self.didTapCell(at: shopName)
        }.store(in: &subscriptions)
        
        noticeListCollectionView.tapNoticeListPublisher.sink { [weak self] noticeId, noticeTitle in
            self?.inputSubject.send(.logEvent(EventParameter.EventLabel.Campus.popularNoticeBanner, .click, noticeTitle))
            let service = DefaultNoticeService()
            let repository = DefaultNoticeListRepository(service: service)
            let fetchNoticedataUseCase = DefaultFetchNoticeDataUseCase(noticeListRepository: repository)
            let downloadNoticeAttachmentUseCase = DefaultDownloadNoticeAttachmentsUseCase(noticeRepository: repository)
            let fetchHotNoticeArticlesUseCase = DefaultFetchHotNoticeArticlesUseCase(noticeListRepository: repository)
            let logAnalyticsEventUseCase = DefaultLogAnalyticsEventUseCase(repository: GA4AnalyticsRepository(service: GA4AnalyticsService()))
            let viewModel = NoticeDataViewModel(fetchNoticeDataUseCase: fetchNoticedataUseCase, fetchHotNoticeArticlesUseCase: fetchHotNoticeArticlesUseCase, downloadNoticeAttachmentUseCase: downloadNoticeAttachmentUseCase, logAnalyticsEventUseCase: logAnalyticsEventUseCase, noticeId: noticeId, boardId: -1)
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
        
        busView.moveBusSearchPublisher.sink { [weak self] in
            self?.inputSubject.send(.logEvent(EventParameter.EventLabel.Campus.mainBusSearch, .click, "가장 빠른 버스 조회하기"))
            let viewModel = BusSearchViewModel(selectBusAreaUseCase: DefaultSelectDepartAndArrivalUseCase(), fetchEmergencyNoticeUseCase: DefaultFetchEmergencyNoticeUseCase(repository: DefaultBusRepository(service: DefaultBusService())), logAnalyticsEventUseCase: DefaultLogAnalyticsEventUseCase(repository: GA4AnalyticsRepository(service: GA4AnalyticsService())))
            let viewController = BusSearchViewController(viewModel: viewModel)
            viewController.title = "교통편 조회하기"
            self?.navigationController?.pushViewController(viewController, animated: true)
        }.store(in: &subscriptions)
        
        busView.moveBusTimetablePublisher.sink {[weak self] in
            self?.inputSubject.send(.logEvent(EventParameter.EventLabel.Campus.mainBusTimetable, .click, "버스 시간표 바로가기"))
            let repository = DefaultBusRepository(service: DefaultBusService())
            let viewModel = BusTimetableViewModel(fetchExpressTimetableUseCase: DefaultFetchExpressTimetableUseCase(busRepository: repository), getExpressFiltersUseCase: DefaultGetExpressFilterUseCase(), getCityFiltersUseCase: DefaultGetCityFiltersUseCase(), fetchCityTimetableUseCase: DefaultFetchCityBusTimetableUseCase(busRepository: repository), getShuttleFilterUseCase: DefaultGetShuttleBusFilterUseCase(), fetchShuttleRoutesUseCase: DefaultFetchShuttleBusRoutesUseCase(busRepository: repository), fetchEmergencyNoticeUseCase: DefaultFetchEmergencyNoticeUseCase(repository: repository), logAnalyticsEventUseCase: DefaultLogAnalyticsEventUseCase(repository: GA4AnalyticsRepository(service: GA4AnalyticsService())))
            let viewController = BusTimetableViewController(viewModel: viewModel)
            viewController.title = "버스 시간표"
            self?.navigationController?.pushViewController(viewController, animated: true)
        }.store(in: &subscriptions)
        
        bannerViewControllerA.bannerTapPublisher.sink { [weak self] banner in
            self?.handleBannerTap(banner)
        }.store(in: &subscriptions)
        
        bannerViewControllerB.bannerTapPublisher.sink { [weak self] banner in
            self?.handleBannerTap(banner)
        }.store(in: &subscriptions)
        
        lostItemListView.lostItemListTappedPublisher.sink { [weak self] in
            self?.navigateToLostItemList()
        }.store(in: &subscriptions)
    }
}

extension HomeViewController {
    private func handleBannerTap(_ banner: Banner) {
        inputSubject.send(.logEventDirect(name: "CAMPUS", label: "main_modal", value: banner.title, category: "click"))
        if let version = banner.version {
            // 현재 앱 버전
            let currentVersion = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? ""
            let isOld = isVersion(currentVersion, lowerThan: version)
            if isOld {
                showToast(message: "해당 기능을 사용하기 위해서는 업데이트가 꼭 필요해요")
                  DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                      if let appStoreURL = URL(string: "https://apps.apple.com/kr/app/%EC%BD%94%EC%9D%B8-koreatech-in-%ED%95%9C%EA%B8%B0%EB%8C%80-%EC%BB%A4%EB%AE%A4%EB%8B%88%ED%8B%B0/id1500848622") {
                          UIApplication.shared.open(appStoreURL)
                      }
                  }
                  return
            }
        }
        if let redirect = banner.redirectLink {
            if redirect == "shop" {
                dismiss(animated: true)
                let shopService = DefaultShopService()
                let shopRepository = DefaultShopRepository(service: shopService)
                
                let fetchShopListUseCase = DefaultFetchShopListUseCase(shopRepository: shopRepository)
                let fetchEventListUseCase = DefaultFetchEventListUseCase(shopRepository: shopRepository)
                let fetchShopCategoryListUseCase = DefaultFetchShopCategoryListUseCase(shopRepository: shopRepository)
                let fetchShopBenefitUseCase = DefaultFetchShopBenefitUseCase(shopRepository: shopRepository)
                let fetchBeneficialShopUseCase = DefaultFetchBeneficialShopUseCase(shopRepository: shopRepository)
                let logAnalyticsEventUseCase = DefaultLogAnalyticsEventUseCase(repository: GA4AnalyticsRepository(service: GA4AnalyticsService()))
                let getUserScreenTimeUseCase = DefaultGetUserScreenTimeUseCase()
                

                let viewModel = ShopViewModel(
                    fetchShopListUseCase: fetchShopListUseCase,
                    fetchEventListUseCase: fetchEventListUseCase,
                    fetchShopCategoryListUseCase: fetchShopCategoryListUseCase,
                    fetchShopBenefitUseCase: fetchShopBenefitUseCase,
                    fetchBeneficialShopUseCase: fetchBeneficialShopUseCase,
                    logAnalyticsEventUseCase: logAnalyticsEventUseCase,
                    getUserScreenTimeUseCase: getUserScreenTimeUseCase,
                    selectedId: 0
                )
                let shopViewController = ShopViewController(viewModel: viewModel)
                navigationController?.pushViewController(shopViewController, animated: true)
            } else if redirect == "dining" {
                dismiss(animated: true)
                navigatetoDining()
            } else if redirect == "keyword" {
                dismiss(animated: true)
                let noticeListService = DefaultNoticeService()
                let noticeListRepository = DefaultNoticeListRepository(service: noticeListService)
                let addNotificationKeywordUseCase = DefaultAddNotificationKeywordUseCase(noticeListRepository: noticeListRepository)
                let deleteNotificationKeywordUseCase = DefaultDeleteNotificationKeywordUseCase(noticeListRepository: noticeListRepository)
                let fetchNotificationKeywordUseCase = DefaultFetchNotificationKeywordUseCase(noticeListRepository: noticeListRepository)
                let changeNotiUseCase = DefaultChangeNotiUseCase(notiRepository: DefaultNotiRepository(service: DefaultNotiService()))
                let fetchNotiListUseCase = DefaultFetchNotiListUseCase(notiRepository: DefaultNotiRepository(service: DefaultNotiService()))
                let fetchRecommendedKeywordUseCase = DefaultFetchRecommendedKeywordUseCase(noticeListRepository: noticeListRepository)
                let logAnalyticsEventUseCase = DefaultLogAnalyticsEventUseCase(repository: GA4AnalyticsRepository(service: GA4AnalyticsService()))
                let viewModel = ManageNoticeKeywordViewModel(addNotificationKeywordUseCase: addNotificationKeywordUseCase, deleteNotificationKeywordUseCase: deleteNotificationKeywordUseCase, fetchNotificationKeywordUseCase: fetchNotificationKeywordUseCase, fetchRecommendedKeywordUseCase: fetchRecommendedKeywordUseCase, changeNotiUseCase: changeNotiUseCase, fetchNotiListUseCase: fetchNotiListUseCase, logAnalyticsEventUseCase: logAnalyticsEventUseCase)
                let viewController = ManageNoticeKeywordViewController(viewModel: viewModel)
                navigationController?.pushViewController(viewController, animated: true)
            } else if redirect == "timetable" {
                dismiss(animated: true)
                if viewModel.isLoggedIn {
                    let viewController = TimetableViewController(viewModel: TimetableViewModel())
                    navigationController?.pushViewController(viewController, animated: true)
                } else {
                    showToast(message: "로그인이 필요한 기능입니다.", success: true)
                }
            } else if redirect == "home" {
                dismiss(animated: true)
                return
            } else if redirect == "login" {
                dismiss(animated: true)
                let loginViewController = LoginViewController(viewModel: LoginViewModel(loginUseCase: DefaultLoginUseCase(userRepository: DefaultUserRepository(service: DefaultUserService())), logAnalyticsEventUseCase: DefaultLogAnalyticsEventUseCase(repository: GA4AnalyticsRepository(service: GA4AnalyticsService()))))
                loginViewController.title = "로그인"
                navigationController?.pushViewController(loginViewController, animated: true)
            } else if redirect == "chat" {
                dismiss(animated: true)
                if !viewModel.isLoggedIn {
                    showToast(message: "로그인이 필요한 기능입니다.")
                    return
                }
                let viewController = ChatListTableViewController(viewModel: ChatListTableViewModel())
                navigationController?.pushViewController(viewController, animated: true)
            } else if redirect == "club" {
                dismiss(animated: true)
                navigationController?.pushViewController(ClubWebViewController(parameter: "/clubs"), animated: true)
            }
        }
    }
    private func isVersion(_ currentVersion: String, lowerThan requiredVersion: String) -> Bool {
        let currentComponents = currentVersion.split(separator: ".").compactMap { Int($0) }
        let requiredComponents = requiredVersion.split(separator: ".").compactMap { Int($0) }

        for i in 0..<max(currentComponents.count, requiredComponents.count) {
            let current = i < currentComponents.count ? currentComponents[i] : 0
            let required = i < requiredComponents.count ? requiredComponents[i] : 0
            if current < required { return true }
            if current > required { return false }
        }

        return false
    }
    
    private func showBanner(banner: BannerDto, abTestResult: AssignAbTestResponse) {
        if banner.count == 0 { return }
        let viewController: UIViewController
        if abTestResult.variableName == .bottomBanner {
            bannerViewControllerA.setBanners(banners: banner.banners)
            viewController = BottomSheetViewController(contentViewController: bannerViewControllerA, defaultHeight: 389)
            inputSubject.send(.logEventDirect(name: "AB_TEST", label: "CAMPUS_modal_1", value: "design_A", category: "a/b test 로깅(메인 모달)"))
            inputSubject.send(.logEventDirect(name: "CAMPUS", label: "main_modal_entry", value: banner.banners.first?.title ?? "", category: "entry"))
        } else {
            bannerViewControllerB.setBanners(banners: banner.banners)
            viewController = bannerViewControllerB
            inputSubject.send(.logEventDirect(name: "AB_TEST", label: "CAMPUS_modal_1", value: "design_B", category: "a/b test 로깅(메인 모달)"))
            inputSubject.send(.logEventDirect(name: "CAMPUS", label: "main_modal_entry", value: banner.banners.first?.title ?? "", category: "entry"))
        }
        viewController.modalPresentationStyle = .overFullScreen
        viewController.modalTransitionStyle = .crossDissolve
        self.present(viewController, animated: true)
    }
    
    private func checkAndShowBanner() {
        if let noShowDate = UserDefaults.standard.object(forKey: "noShowBanner") as? Date {
            if let thresholdDate = Calendar.current.date(byAdding: .day, value: 7, to: noShowDate),
               Date() < thresholdDate {
                return
            }
        }
        inputSubject.send(.getBannerAbTest("a_main_banner_ui"))
    }
    
    @objc private func tapBusQrCode() {
        inputSubject.send(.logEvent(EventParameter.EventLabel.Campus.shuttleTicket, .click, "셔틀 탑승권"))
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
    
    private func configureTapGesture() {
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(menuViewTapped))
        menuBackgroundView.addGestureRecognizer(tapGesture)
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
    
    private func updateDining(item: DiningItem?, type: DiningType, isToday: Bool) {
        menuBackgroundView.updateDining(item, type)
        if isToday {
            self.menuLabel.text = "오늘 식단"
        }
        else {
            self.menuLabel.text = "내일 식단"
        }
    }
    
    private func updateHotArticles(articles: [NoticeArticleDto], phrases: ((String, String), Int)?) {
        noticeListCollectionView.updateNoticeList(articles, phrases)
        
        let hasKeywordBanner = phrases != nil ? 1 : 0
        noticePageControl.numberOfPages = articles.count + hasKeywordBanner
    }
    
    private func putImage(data: ShopCategoryDto) {
        categoryCollectionView.updateCategories(data.shopCategories)
    }
    
    private func setAbTestResult(result: AssignAbTestResponse) {
        if result.variableName == .mainDiningOriginal {
            goDiningPageButton.isHidden = true
        }
        else if result.variableName == .mainDiningNew {
            goDiningPageButton.isHidden = false
        }
    }
    
    private func didTapCell(at id: Int) {
        let shopService = DefaultShopService()
        let shopRepository = DefaultShopRepository(service: shopService)
        let fetchShopListUseCase = DefaultFetchShopListUseCase(shopRepository: shopRepository)
        let fetchEventListUseCase = DefaultFetchEventListUseCase(shopRepository: shopRepository)
        let fetchShopCategoryListUseCase = DefaultFetchShopCategoryListUseCase(shopRepository: shopRepository)
        let fetchShopBenefitUseCase = DefaultFetchShopBenefitUseCase(shopRepository: shopRepository)
        let fetchBeneficialShopUseCase = DefaultFetchBeneficialShopUseCase(shopRepository: shopRepository)
        let logAnalyticsEventUseCase = DefaultLogAnalyticsEventUseCase(repository: GA4AnalyticsRepository(service: GA4AnalyticsService()))
        let getUserScreenTimeUseCase = DefaultGetUserScreenTimeUseCase()
        let viewModel = ShopViewModel(
            fetchShopListUseCase: fetchShopListUseCase,
            fetchEventListUseCase: fetchEventListUseCase,
            fetchShopCategoryListUseCase: fetchShopCategoryListUseCase,
            fetchShopBenefitUseCase: fetchShopBenefitUseCase,
            fetchBeneficialShopUseCase: fetchBeneficialShopUseCase,
            logAnalyticsEventUseCase: logAnalyticsEventUseCase,
            getUserScreenTimeUseCase: getUserScreenTimeUseCase,
            selectedId: id
        )
        let viewController = ShopViewController(viewModel: viewModel)
        navigationController?.pushViewController(viewController, animated: true)
    }
    
    @objc private func refresh() {
        inputSubject.send(.categorySelected(getDiningPlace()))
        refreshControl.endRefreshing()
    }
    
    // navigate 함수
    private func navigateToLostItemList() {
        let userRepository = DefaultUserRepository(service: DefaultUserService())
        let lostItemRepository = DefaultLostItemRepository(service: DefaultLostItemService())
        let checkLoginUseCase = DefaultCheckLoginUseCase(userRepository: userRepository)
        let fetchLostItemItemUseCase = DefaultFetchLostItemListUseCase(repository: lostItemRepository)
        let viewModel = LostItemListViewModel(checkLoginUseCase: checkLoginUseCase, fetchLostItemListUseCase: fetchLostItemItemUseCase)
        let viewController = LostItemListViewController(viewModel: viewModel)
        navigationController?.pushViewController(viewController, animated: true)
    }
    
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

// AB Test
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
        [noticeLabel, noticeListCollectionView, noticePageControl, goNoticePageButton, busLabel, diningTooltipImageView, lostItemListView, orderLabel, categoryCollectionView, menuLabel, menuBackgroundView, tabBarView, grayColorView, goDiningPageButton, busView, busQrCodeButton, clubView].forEach {
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
        
        clubView.snp.makeConstraints { make in
            make.top.equalTo(busView.snp.bottom).offset(24)
            make.horizontalEdges.equalTo(scrollView)
        }
        
        lostItemListView.snp.makeConstraints {
            $0.top.equalTo(clubView.snp.bottom).offset(30)
            $0.leading.trailing.equalTo(scrollView)
        }
        
        orderLabel.snp.makeConstraints { make in
            make.top.equalTo(lostItemListView.snp.bottom).offset(30)
            make.height.equalTo(22)
            make.leading.equalTo(scrollView.snp.leading).offset(20)
            make.trailing.equalTo(scrollView.snp.trailing)
        }
        
        categoryCollectionView.snp.makeConstraints { make in
            make.top.equalTo(orderLabel.snp.bottom).offset(11)
            make.leading.equalTo(scrollView.snp.leading)
            make.trailing.equalTo(scrollView.snp.trailing)
            make.height.equalTo(166)
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
