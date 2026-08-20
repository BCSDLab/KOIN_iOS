//
//  SceneDelegate.swift
//  Koin
//
//  Created by 김나훈 on 1/14/24.
//

import UIKit

class SceneDelegate: UIResponder, UIWindowSceneDelegate {
    
    // MARK: - Properties
    var window: UIWindow?
    private var isPresentingErrorViewController = false
    private var handledMessageIds: [String] = []
    
    var navigationController: UINavigationController? {
        (window?.rootViewController as? HomeTabBarController)?.selectedViewController as? UINavigationController
    }
    
    // MARK: - Initializer
    override init() {
        super.init()
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(presentErrorViewController),
            name: NSNotification.Name("ServerError"),
            object: nil
        )
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    // MARK: - cold start
    func scene(
        _ scene: UIScene,
        willConnectTo session: UISceneSession,
        options connectionOptions: UIScene.ConnectionOptions
    ) {
        // cold start
        guard let windowScene = (scene as? UIWindowScene) else { return }
        let window = UIWindow(windowScene: windowScene)
        window.rootViewController = makeHomeTabBarController()
        
        self.window = window
        window.makeKeyAndVisible()
        
        // MARK: - 딥링크 Cold Start
        if let userActivity = connectionOptions.userActivities.first(where: { $0.activityType == NSUserActivityTypeBrowsingWeb }),
           let incomingURL = userActivity.webpageURL {
            handleIncomingDeepLink(url: incomingURL)
        } else if let urlContext = connectionOptions.urlContexts.first {
            handleIncomingDeepLink(url: urlContext.url)
        }
        
        // MARK: - 푸시알림 Cold Start
        if let userInfo = connectionOptions.notificationResponse?.notification.request.content.userInfo {
            handleNotificationData(userInfo: userInfo)
        }
    }
    
    // MARK: - 딥링크 (Universal Link) warm start
    func scene(
        _ scene: UIScene,
        continue userActivity: NSUserActivity
    ) {
        guard userActivity.activityType == NSUserActivityTypeBrowsingWeb,
              let incomingURL = userActivity.webpageURL else { return }
        handleIncomingDeepLink(url: incomingURL)
    }
    
    // MARK: - 딥링크 (URI Scheme) warm start
    func scene(
        _ scene: UIScene,
        openURLContexts URLContexts: Set<UIOpenURLContext>
    ) {
        guard let urlContext = URLContexts.first else { return }
        handleIncomingDeepLink(url: urlContext.url)
    }
}

extension SceneDelegate {
    
    private func handleIncomingDeepLink(
        url: URL
    ) {
        // URL 경로가 "/articles/lost-item"인 경우에 처리
        if url.host == "lost-item" || (url.host == "articles" && url.path == "/lost-item") {
            handleLostItemNavigation(navigationController: navigationController)
        }
        
        // 카카오톡 식단공유
        guard let components = URLComponents(url: url, resolvingAgainstBaseURL: false) else { return }
        
        var parameters: [String: String] = [:]
        components.queryItems?.forEach { queryItem in
            parameters[queryItem.name] = queryItem.value
        }
        
        if let date = parameters["date"], let type = parameters["type"], let place = parameters["place"] {
            handleDiningNavigation(date: date, type: type, place: place, navigationController: navigationController)
            let logAnalyticsEventUseCase = DefaultLogAnalyticsEventUseCase(repository: GA4AnalyticsRepository(service: GA4AnalyticsService()))
            logAnalyticsEventUseCase.execute(label: EventParameter.EventLabel.Campus.menuShare, category: .click, value: "코인으로 이동")
            return
        }
    }
    
    // MARK: - 푸시알림 처리
    func handleNotificationData(userInfo: [AnyHashable: Any]) {
        // Cold Start 푸시알림 중복처리 방지
        guard let messageId = userInfo["gcm.message_id"] as? String,
              !handledMessageIds.contains(messageId) else {
            return
        }
        handledMessageIds.append(messageId)
        
        guard let aps = userInfo["aps"] as? [String: AnyObject],
              let category = aps["category"] as? String,
              let appPath = AppPath(rawValue: category),
              let schemeUri = userInfo["schemeUri"] as? String,
              let parsedQuery = parseQuery(uri: schemeUri) else {
            print("Invalid notification data")
            return
        }
        
        switch appPath {
        case .shop:
            if let shopId = Int(parsedQuery["id"]) {
                let shopSummaryViewController = makeShopSummaryViewController(shopId: shopId)
                navigationController?.pushViewController(shopSummaryViewController, animated: true)
            }
        case .dining:
            let diningViewController = makeDiningViewController()
            navigationController?.pushViewController(diningViewController, animated: true)
        case .chat:
            if let articleId = Int(parsedQuery["articleId"]),
               let chatRoomId = Int(parsedQuery["chatRoomId"]) {
                let viewModel = LostItemChatViewModel(articleId: articleId, chatRoomId: chatRoomId, articleTitle: nil)
                let chatViewController = LostItemChatViewController(viewModel: viewModel)
                navigationController?.pushViewController(chatViewController, animated: true)
            }
        case .callvan:
            if let postId = Int(parsedQuery["id"]) {
                let callVanDataViewController = makeCallVanDataViewController(postId: postId)
                navigationController?.pushViewController(callVanDataViewController, animated: true)
            }
        case .callvanChat:
            if let postId = Int(parsedQuery["postId"]) {
                let callVanChatViewController = makeCallVanChatViewController(postId: postId)
                navigationController?.pushViewController(callVanChatViewController, animated: true)
            }
        case .keyword:
            guard let noticeId = Int(parsedQuery["id"]),
                  let boardId = Int(parsedQuery["board-id"]) else {
                return
            }
            let viewController: UIViewController
            if boardId == 14 {
                viewController = makeLostItemData(lostItemId: noticeId)
            } else {
                viewController = makeNoticeDataViewController(noticeId: noticeId, boardId: boardId)
            }
            navigationController?.pushViewController(viewController, animated: true)
        }
    }
}

extension SceneDelegate {
    
    private func makeHomeTabBarController() -> HomeTabBarController {
        let homeViewController = makeHomeHostingController()
        let categoryViewController = makeCategoryHostingController()
        let noticeViewController = makeNoticeListViewController()
        let profileViewController = makeProfileHostingController()
        
        let logAnalyticsEventUseCase = DefaultLogAnalyticsEventUseCase(repository: GA4AnalyticsRepository(service: GA4AnalyticsService()))
        let checkHasUnreadNotificationHistoryUseCase = DefaultCheckHasUnreadNotificationHistoryUseCase(repository: DefaultNotificationHistoryRepository(service: DefaultNotificationHistoryService()))
        let viewModel = HomeTabBarViewModel(
            logAnalyticsEventUseCase: logAnalyticsEventUseCase,
            checkHasUnreadNotificationHistoryUseCase: checkHasUnreadNotificationHistoryUseCase
        )

        return HomeTabBarController(
            items: [
                .init(viewController: homeViewController, tab: .home),
                .init(viewController: categoryViewController, tab: .category),
                .init(viewController: noticeViewController, tab: .board),
                .init(viewController: profileViewController, tab: .profile)
            ],
            viewModel: viewModel
        )
    }

    private func makeHomeHostingController() -> UIViewController {
        let callVanRepository = DefaultCallVanRepository(service: DefaultCallVanService())
        let shopRepository = DefaultShopRepository(service: DefaultShopService())
        let coreRepository = DefaultCoreRepository(service: DefaultCoreService())
        let userRepository = DefaultUserRepository(service: DefaultUserService())
        let notiRepository = DefaultNotiRepository(service: DefaultNotiService())
        let diningRepository = DefaultDiningRepository(diningService: DefaultDiningService(), shareService: KakaoShareService())
        let homeRepository = DefaultHomeRepository(service: DefaultHomeService())

        let fetchHomeHeaderUseCase = DefaultFetchHomeHeaderUseCase(homeRepository: homeRepository, userRepository: userRepository)
        let fetchHomeDiningListUseCase = DefaultFetchHomeDiningListUseCase(
            fetchDiningListUseCase: DefaultFetchDiningListUseCase(diningRepository: diningRepository),
            fetchCoopShopListUseCase: DefaultFetchCoopShopListUseCase(diningRepository: diningRepository),
            dateProvider: DefaultDateProvider()
        )
        let fetchCountsUseCase = DefaultFetchHomeCountsUseCase(
            shopRepository: shopRepository,
            callvanRepository: callVanRepository
        )
        let checkVersionUseCase = DefaultCheckVersionUseCase(coreRepository: coreRepository)
        let fetchUserDataUseCase = DefaultFetchUserDataUseCase(userRepository: userRepository)
        let SendDeviceTokenIfNeededUseCase = DefaultSendDeviceTokenIfNeededUseCase(
            userRepository: userRepository,
            notiRepository: notiRepository
        )
        let logAnalyticsEventUseCase = DefaultLogAnalyticsEventUseCase(repository: GA4AnalyticsRepository(service: GA4AnalyticsService()))
        
        let viewModel = HomeViewModel(
            fetchHomeHeaderUseCase: fetchHomeHeaderUseCase,
            fetchHomeDiningListUseCase: fetchHomeDiningListUseCase,
            fetchCountsUseCase: fetchCountsUseCase,
            checkVersionUseCase: checkVersionUseCase,
            checkLoginUseCase: DefaultCheckLoginUseCase(userRepository: userRepository),
            fetchUserDataUseCase: fetchUserDataUseCase,
            sendDeviceTokenIfNeededUseCase: SendDeviceTokenIfNeededUseCase,
            logAnalyticsEventUseCase: logAnalyticsEventUseCase,
            fetchBannerUseCase: DefaultFetchBannerUseCase(coreRepository: coreRepository)
        )
        let homeView = HomeView(viewModel: viewModel)
        return HomeHostingController(rootView: homeView)
    }
    
    private func makeCategoryHostingController() -> UIViewController {
        let checkLoginUseCase = DefaultCheckLoginUseCase(userRepository: DefaultUserRepository(service: DefaultUserService()))
        let logAnalyticsEventUseCase = DefaultLogAnalyticsEventUseCase(repository: GA4AnalyticsRepository(service: GA4AnalyticsService()))
        let categoryRootView = CategoryView(
            viewModel: CategoryViewModel(
                checkLoginUseCase: checkLoginUseCase,
                logAnalyticsEventUseCase: logAnalyticsEventUseCase))
        return CategoryHostingController(rootView: categoryRootView)
    }
    
    private func makeNoticeListViewController() -> UIViewController {
        let service = DefaultNoticeService()
        let repository = DefaultNoticeListRepository(service: service)
        let fetchArticleListUseCase = DefaultFetchNoticeArticlesUseCase(noticeListRepository: repository)
        let fetchMyKeywordUseCase = DefaultFetchNotificationKeywordUseCase(noticeListRepository: repository)
        let logAnalyticsEventUseCase = DefaultLogAnalyticsEventUseCase(
            repository: GA4AnalyticsRepository(service: GA4AnalyticsService())
        )
        let viewModel = NoticeListViewModel(
            fetchNoticeArticlesUseCase: fetchArticleListUseCase,
            fetchMyKeywordUseCase: fetchMyKeywordUseCase,
            logAnalyticsEventUseCase: logAnalyticsEventUseCase
        )
        return NoticeListViewController(viewModel: viewModel)
    }
    
    private func makeProfileHostingController() -> UIViewController {
        let timeTableRepository = DefaultTimetableRepository(service: DefaultTimetableService())
        let logAnalyticsEventUseCase = DefaultLogAnalyticsEventUseCase(repository: GA4AnalyticsRepository(service: GA4AnalyticsService()))
        let deleteDeviceTokenUseCase = DefaultDeleteDeviceTokenUseCase(repository: DefaultNotiRepository(service: DefaultNotiService()))
        let fetchUserDataUseCase = DefaultFetchUserDataUseCase(userRepository: DefaultUserRepository(service: DefaultUserService()))
        let fetchMainFrameUseCase = DefaultFetchMainFrameUseCase(
            fetchFramesUseCase: DefaultFetchFramesUseCase(timetableRepository: timeTableRepository),
            fetchFrameUseCase: DefaultFetchFrameUseCase(timetableRepository: timeTableRepository),
            fetchLectureUseCase: DefaultFetchLectureUseCase(timetableRepository: timeTableRepository)
        )
        let profileViewModel = ProfileViewModel(
            logAnalyticsEventUseCase: logAnalyticsEventUseCase,
            deleteDeviceTokenUseCase: deleteDeviceTokenUseCase,
            fetchUserDataUseCase: fetchUserDataUseCase,
            fetchMainFrameUseCase: fetchMainFrameUseCase
        )
        let profileView = ProfileView(viewModel: profileViewModel)
        return ProfileHostingController(rootView: profileView)
    }

    @objc private func presentErrorViewController() {
        
        guard isPresentingErrorViewController == false else {
            return
        }
        
        let completion: ()->Void = { [weak self] in
            self?.window?.rootViewController = self?.makeHomeTabBarController()
            self?.window?.rootViewController?.dismiss(animated: true) {
                self?.isPresentingErrorViewController = false
            }
        }
        let errorViewController = ErrorViewController(completion: completion).then {
            $0.modalPresentationStyle = .fullScreen
        }
        
        DispatchQueue.main.async { [weak self] in
            if let _ = self?.navigationController?.presentedViewController {
                self?.navigationController?.dismiss(animated: true) {
                    self?.navigationController?.present(errorViewController, animated: true)
                }
            } else {
                self?.navigationController?.present(errorViewController, animated: true)
            }
        }
        isPresentingErrorViewController = true
    }
    
    private func handleDiningNavigation(date: String, type: String, place: String, navigationController: UINavigationController?) {
        let diningService = DefaultDiningService()
        let shareService = KakaoShareService()
        let diningRepository = DefaultDiningRepository(diningService: diningService, shareService: shareService)
        let notiRepository = DefaultNotiRepository(service: DefaultNotiService())
        let fetchDiningListUseCase = DefaultFetchDiningListUseCase(diningRepository: diningRepository)
        let logAnalyticsEventUseCase = DefaultLogAnalyticsEventUseCase(repository: GA4AnalyticsRepository(service: GA4AnalyticsService()))
        let dateProvider = DefaultDateProvider()
        let shareMenuListUseCase = DefaultShareMenuListUseCase(diningRepository: diningRepository)
        let changeNotiUseCase = DefaultChangeNotiUseCase(notiRepository: notiRepository)
        let changeNotiDetailUseCase = DefaultChangeNotiDetailUseCase(notiRepository: notiRepository)
        let fetchNotiListUseCase = DefaultFetchNotiListUseCase(notiRepository: notiRepository)
        let viewModel = DiningViewModel(
            fetchDiningListUseCase: fetchDiningListUseCase,
            logAnalyticsEventUseCase: logAnalyticsEventUseCase,
            dateProvder: dateProvider,
            shareMenuListUseCase: shareMenuListUseCase,
            changeNotiUseCase: changeNotiUseCase,
            fetchNotiListUsecase: fetchNotiListUseCase,
            changeNotiDetailUseCase: changeNotiDetailUseCase,
            sharedDiningItem: CurrentDiningTime(date: date.toDateFromYYMMDD() ?? Date(), diningType: DiningType(rawValue: "\(type)") ?? .breakfast)
        )
        let diningViewController = DiningViewController(viewModel: viewModel)
        diningViewController.title = "식단"
        
        navigationController?.pushViewController(diningViewController, animated: true)
    }
    
    private func makeCallVanDataViewController(postId: Int) -> CallVanDataViewController {
        let callVanRepository = DefaultCallVanRepository(service: DefaultCallVanService())
        let fetchCallVanDataUseCase = DefaultFetchCallVanDataUseCase(repository: callVanRepository)
        let fetchCallVanNotificationListUseCase = DefaultFetchCallVanNotificationListUseCase(repository: callVanRepository)
        let logAnalyticsEventUseCase = DefaultLogAnalyticsEventUseCase(repository: GA4AnalyticsRepository(service: GA4AnalyticsService()))
        let viewModel = CallVanDataViewModel(
            postId: postId,
            fetchCallVanDataUseCase: fetchCallVanDataUseCase,
            fetchCallVanNotificationListUseCase: fetchCallVanNotificationListUseCase,
            logAnalyticsEventUseCase: logAnalyticsEventUseCase)
        let callVanDataViewController = CallVanDataViewController(viewModel: viewModel)
        return callVanDataViewController
    }
    
    private func makeCallVanChatViewController(postId: Int) -> CallVanChatViewController {
        let callVanRepository = DefaultCallVanRepository(service: DefaultCallVanService())
        let coreRepository = DefaultCoreRepository(service: DefaultCoreService())
        let fetchCallVanChatUseCase = DefaultFetchCallVanChatUseCase(repository: callVanRepository)
        let postCallVanChatUseCase = DefaultPostCallVanChatUseCase(repository: callVanRepository)
        let fetchCallVanDataUseCase = DefaultFetchCallVanDataUseCase(repository: callVanRepository)
        let uploadFileUseCase = DefaultUploadFileUseCase(coreRepository: coreRepository)
        let logAnalyticsEventUseCase = DefaultLogAnalyticsEventUseCase(repository: GA4AnalyticsRepository(service: GA4AnalyticsService()))
        let viewModel = CallVanChatViewModel(
            postId: postId,
            fetchCallVanChatUseCase: fetchCallVanChatUseCase,
            postCallVanChatUseCase: postCallVanChatUseCase,
            fetchCallVanDataUseCase: fetchCallVanDataUseCase,
            uploadFileUseCase: uploadFileUseCase,
            logAnalyticsEventUseCase: logAnalyticsEventUseCase)
        let callVanChatViewController = CallVanChatViewController(viewModel: viewModel)
        return callVanChatViewController
    }

    private func makeLostItemData(lostItemId: Int) -> UIViewController {
        let userRepository = DefaultUserRepository(service: DefaultUserService())
        let lostItemRepository = DefaultLostItemRepository(service: DefaultLostItemService())
        let chatRepository = DefaultLostItemRepository(service: DefaultLostItemService())
        let checkLoginUseCase = DefaultCheckLoginUseCase(userRepository: userRepository)
        let fetchLostItemDataUseCase = DefaultFetchLostItemDataUseCase(repository: lostItemRepository)
        let fetchLostItemListUseCase = DefaultFetchLostItemListUseCase(repository: lostItemRepository)
        let changeLostItemStateUseCase = DefaultChangeLostItemStateUseCase(repository: lostItemRepository)
        let deleteLostItemUseCase = DefaultDeleteLostItemUseCase(repository: lostItemRepository)
        let createChatRoomUseCase = DefaultLostItemCreateChatRoomUseCase(chatRepository: chatRepository)
        let logAnalyticsEventUseCase = DefaultLogAnalyticsEventUseCase(repository: GA4AnalyticsRepository(service: GA4AnalyticsService()))
        let viewModel = LostItemDataViewModel(
            checkLoginUseCase: checkLoginUseCase,
            fetchLostItemDataUseCase: fetchLostItemDataUseCase,
            fetchLostItemListUseCase: fetchLostItemListUseCase,
            changeLostItemStateUseCase: changeLostItemStateUseCase,
            deleteLostItemUseCase: deleteLostItemUseCase,
            createChatRoomUseCase: createChatRoomUseCase,
            logAnalyticsEventUseCase: logAnalyticsEventUseCase,
            id: lostItemId)
        return LostItemDataViewController(viewModel: viewModel)
    }
    
    private func makeNoticeDataViewController(noticeId: Int, boardId: Int) -> NoticeDataViewController {
        let service = DefaultNoticeService()
        let repository = DefaultNoticeListRepository(service: service)
        let viewModel = NoticeDataViewModel(
            fetchNoticeDataUseCase: DefaultFetchNoticeDataUseCase(noticeListRepository: repository),
            fetchHotNoticeArticlesUseCase: DefaultFetchHotNoticeArticlesUseCase(noticeListRepository: repository),
            downloadNoticeAttachmentUseCase: DefaultDownloadNoticeAttachmentsUseCase(noticeRepository: repository),
            logAnalyticsEventUseCase: DefaultLogAnalyticsEventUseCase(repository: GA4AnalyticsRepository(service: GA4AnalyticsService())),
            noticeId: noticeId,
            boardId: boardId
        )
        return NoticeDataViewController(viewModel: viewModel)
    }
    
    private func makeDiningViewController() -> DiningViewController {
        let diningService = DefaultDiningService()
        let shareService = KakaoShareService()
        let diningRepository = DefaultDiningRepository(diningService: diningService, shareService: shareService)
        let notiRepository = DefaultNotiRepository(service: DefaultNotiService())
        let fetchDiningListUseCase = DefaultFetchDiningListUseCase(diningRepository: diningRepository)
        let logAnalyticsEventUseCase = DefaultLogAnalyticsEventUseCase(repository: GA4AnalyticsRepository(service: GA4AnalyticsService()))
        let dateProvider = DefaultDateProvider()
        let shareMenuListUseCase = DefaultShareMenuListUseCase(diningRepository: diningRepository)
        let changeNotiUseCase = DefaultChangeNotiUseCase(notiRepository: notiRepository)
        let changeNotiDetailUseCase = DefaultChangeNotiDetailUseCase(notiRepository: notiRepository)
        let fetchNotiListUseCase = DefaultFetchNotiListUseCase(notiRepository: notiRepository)
        let viewModel = DiningViewModel(fetchDiningListUseCase: fetchDiningListUseCase, logAnalyticsEventUseCase: logAnalyticsEventUseCase, dateProvder: dateProvider, shareMenuListUseCase: shareMenuListUseCase, changeNotiUseCase: changeNotiUseCase, fetchNotiListUsecase: fetchNotiListUseCase, changeNotiDetailUseCase: changeNotiDetailUseCase)
        let diningViewController = DiningViewController(viewModel: viewModel)
        diningViewController.title = "식단"
        return diningViewController
    }
    
    private func makeShopSummaryViewController(shopId: Int) -> UIViewController {
        let repository = DefaultShopRepository(service: DefaultShopService())
        let fetchOrderShopSummaryFromShopUseCase = DefaultFetchOrderShopSummaryFromShopUseCase(repository: repository)
        let fetchOrderShopMenusAndGroupsFromShopUseCase = DefaultFetchOrderShopMenusAndGroupsFromShopUseCase(shopRepository: repository)
        let fetchShopDataUseCase = DefaultFetchShopDataUseCase(shopRepository: repository)
        let fetchShopEventListUseCase = DefaultFetchShopEventListUseCase(shopRepository: repository)
        let logAnalyticsEventUseCase = DefaultLogAnalyticsEventUseCase(repository: GA4AnalyticsRepository(service: GA4AnalyticsService()))
        let getUserScreenTimeUseCase = DefaultGetUserScreenTimeUseCase()
        let viewModel = ShopSummaryViewModel(
            fetchOrderShopSummaryFromShopUseCase: fetchOrderShopSummaryFromShopUseCase,
            fetchOrderShopMenusAndGroupsFromShopUseCase: fetchOrderShopMenusAndGroupsFromShopUseCase,
            fetchShopDataUseCase: fetchShopDataUseCase,
            fetchShopEventListUseCase: fetchShopEventListUseCase,
            logAnalyticsEventUseCase: logAnalyticsEventUseCase,
            getUserScreenTimeUseCase: getUserScreenTimeUseCase,
            shopId: shopId,
            shopName: nil
        )
        return ShopSummaryViewController(viewModel: viewModel)
    }
    
    private func makeTimeTableViewController() -> TimetableViewController {
        let viewController = TimetableViewController(viewModel: TimetableViewModel())
        return viewController
    }
    
    private func handleLostItemNavigation(navigationController: UINavigationController?) {
        let userRepository = DefaultUserRepository(service: DefaultUserService())
        let lostItemRepository = DefaultLostItemRepository(service: DefaultLostItemService())
        let checkLoginUseCase = DefaultCheckLoginUseCase(userRepository: userRepository)
        let fetchLostItemListUseCase = DefaultFetchLostItemListUseCase(repository: lostItemRepository)
        let logAnalyticsEventUseCase = DefaultLogAnalyticsEventUseCase(repository: GA4AnalyticsRepository(service: GA4AnalyticsService()))
        let fetchMyKeywordUseCase = DefaultFetchLostItemMyKeywordUseCase(repository: lostItemRepository)
        let viewModel = LostItemListViewModel(
            checkLoginUseCase: checkLoginUseCase,
            fetchLostItemListUseCase: fetchLostItemListUseCase,
            logAnalyticsEventUseCase: logAnalyticsEventUseCase,
            fetchMyKeywordUseCase: fetchMyKeywordUseCase
        )
        let viewController = LostItemListViewController(viewModel: viewModel)
        navigationController?.pushViewController(viewController, animated: false)
    }
}

extension SceneDelegate {
    private func parseQuery(uri: String) -> [String: String]? {
        if let components = URLComponents(string: uri),
           let qureyItems = components.queryItems {
            return qureyItems.reduce(into: [:]) { result, item in
                result[item.name] = item.value
            }
        } else {
            return nil
        }
    }
}
