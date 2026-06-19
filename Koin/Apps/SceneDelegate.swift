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
    var coordinator: RootCoordinator?
    
    // MARK: - cold start & 딥링크
    func scene(
        _ scene: UIScene,
        willConnectTo session: UISceneSession,
        options connectionOptions: UIScene.ConnectionOptions
    ) {
        // cold start
        guard let windowScene = (scene as? UIWindowScene) else { return }
        let window = UIWindow(windowScene: windowScene)
        let navigationController = CustomNavigationController()
        self.coordinator = makeAppCooridnator(navigationController: navigationController)
        window.rootViewController = navigationController
        self.window = window
        window.makeKeyAndVisible()
        Task {
            await coordinator?.start()
        }
        
        // 딥링크
        if let userActivity = connectionOptions.userActivities.first(where: { $0.activityType == NSUserActivityTypeBrowsingWeb }),
           let incomingURL = userActivity.webpageURL {
            handleIncomingDeepLink(url: incomingURL, navigationController: navigationController)
        } else if let urlContext = connectionOptions.urlContexts.first {
            handleIncomingDeepLink(url: urlContext.url, navigationController: navigationController)
        }
    }
    
    // MARK: - 딥링크 (Universal Link) warm start
    func scene(
        _ scene: UIScene,
        continue userActivity: NSUserActivity
    ) {
        guard userActivity.activityType == NSUserActivityTypeBrowsingWeb,
              let incomingURL = userActivity.webpageURL else { return }
        
        handleIncomingDeepLink(url: incomingURL, navigationController: window?.rootViewController as? UINavigationController)
    }
    
    // MARK: - 딥링크 (URI Scheme) warm start
    func scene(
        _ scene: UIScene,
        openURLContexts URLContexts: Set<UIOpenURLContext>
    ) {
        guard let urlContext = URLContexts.first else { return }
        handleIncomingDeepLink(url: urlContext.url, navigationController: window?.rootViewController as? UINavigationController)
    }
    
    // MARK: - 푸시알림 처리 (AppDelegate에 의해 호출)
    func handleNotificationData(userInfo: [AnyHashable: Any]) {
        handleNotificationData(userInfo: userInfo, navigationController: window?.rootViewController as? UINavigationController)
    }
}

extension SceneDelegate {
    
    private func handleIncomingDeepLink(
        url: URL,
        navigationController: UINavigationController?
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
    
    private func handleNotificationData(userInfo: [AnyHashable: Any], navigationController: UINavigationController?) {
        guard let aps = userInfo["aps"] as? [String: AnyObject], let category = aps["category"] as? String,
              let category = AppPath(rawValue: category) else {
            print("Invalid notification data")
            return
        }
        let schemeUri = userInfo["schemeUri"] as? String
        
        switch category {
        case .home, .login, .club:
            break
        case .shop:
            let shopViewController = makeShopViewController()
            navigationController?.pushViewController(shopViewController, animated: true)
        case .dining:
            let diningViewController = makeDiningViewController()
            navigationController?.pushViewController(diningViewController, animated: true)
        case .timeTable:
            let timeTableViewController = makeTimeTableViewController()
            navigationController?.pushViewController(timeTableViewController, animated: true)
        case .keyword:
            guard let id = extractValue(from: schemeUri, value: "id"), let intId = Int(id) else {
                print("noticeId : Invalid or missing")
                return
            }
            
            let noticeDataViewController = makeNoticeDataViewController(noticeId: intId)
            navigationController?.pushViewController(noticeDataViewController, animated: true)
            
            if let keyword = extractValue(from: schemeUri, value: "keyword") {
                DefaultLogAnalyticsEventUseCase(
                    repository: GA4AnalyticsRepository(service: GA4AnalyticsService())
                ).execute(
                    label: EventParameter.EventLabel.Campus.keywordNotification,
                    category: .notification,
                    value: keyword
                )
            }
        case .chat:
            guard let articleId = extractValue(from: schemeUri, value: "articleId"), let intArticleId = Int(articleId) else {
                print("articleId : Invalid or missing")
                return
            }
            guard let chatRoomId = extractValue(from: schemeUri, value: "chatRoomId"), let intChatRoomId = Int(chatRoomId) else {
                print("chatRoomId : Invalid or missing")
                return
            }
            let viewModel = ChatViewModel(articleId: intArticleId, chatRoomId: intChatRoomId, articleTitle: nil)
            let chatViewController = ChatViewController(viewModel: viewModel)
            navigationController?.pushViewController(chatViewController, animated: true)
        case .callvan:
            guard let postId = extractValue(from: schemeUri, value: "id"), let intPostId = Int(postId) else {
                print("postId : Invalid or missing")
                return
            }
            let callVanDataViewController = makeCallVanDataViewController(postId: intPostId)
            navigationController?.pushViewController(callVanDataViewController, animated: true)
        case .callvanChat:
            guard let postId = extractValue(from: schemeUri, value: "postId"), let intPostId = Int(postId) else {
                print("postId : Invalid or missing")
                return
            }
            let callVanChatViewController = makeCallVanChatViewController(postId: intPostId)
            navigationController?.pushViewController(callVanChatViewController, animated: true)
        }
    }
}

extension SceneDelegate {
    
    private func makeAppCooridnator(navigationController: CustomNavigationController) -> AppCoordinator {
        let repository = GA4AnalyticsRepository(service: GA4AnalyticsService())
        let logAnalyticsEventUseCase = DefaultLogAnalyticsEventUseCase(repository: repository)
        return AppCoordinator(
            navigationController: navigationController,
            appLaunchPresentationUseCase: makeAppLaunchPresentationUseCase(),
            logAnalyticsEventUseCase: logAnalyticsEventUseCase
        )
    }
    
    private func makeAppLaunchPresentationUseCase() -> AppLaunchPresentationUseCase {
        let coreRepository = DefaultCoreRepository(service: DefaultCoreService())
        let userRepository = DefaultUserRepository(service: DefaultUserService())
        let checkVersionUseCase = DefaultCheckVersionUseCase(coreRepository: coreRepository)
        let checkModifyUserNeededUseCase = DefaultCheckModifyUserNeededUseCase(userRepository: userRepository)
        return DefaultAppLaunchPresentationUseCase(
            checkVersionUseCase: checkVersionUseCase,
            checkModifyUserNeededUseCase: checkModifyUserNeededUseCase
        )
    }
    
    private func handleDiningNavigation(date: String, type: String, place: String, navigationController: UINavigationController?) {
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
        let viewModel = DiningViewModel(
            fetchDiningListUseCase: fetchDiningListUseCase,
            logAnalyticsEventUseCase: logAnalyticsEventUseCase,
            dateProvder: dateProvider,
            shareMenuListUseCase: shareMenuListUseCase,
            diningLikeUseCase: diningLikeUseCase,
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

    private func makeNoticeDataViewController(noticeId: Int) -> NoticeDataViewController {
        let service = DefaultNoticeService()
        let repository = DefaultNoticeListRepository(service: service)
        let viewModel = NoticeDataViewModel(
            fetchNoticeDataUseCase: DefaultFetchNoticeDataUseCase(noticeListRepository: repository),
            fetchHotNoticeArticlesUseCase: DefaultFetchHotNoticeArticlesUseCase(noticeListRepository: repository),
            downloadNoticeAttachmentUseCase: DefaultDownloadNoticeAttachmentsUseCase(noticeRepository: repository),
            logAnalyticsEventUseCase: DefaultLogAnalyticsEventUseCase(repository: GA4AnalyticsRepository(service: GA4AnalyticsService())),
            noticeId: noticeId, boardId: -1
        )
        let viewController = NoticeDataViewController(viewModel: viewModel)
        return viewController
    }
    
    private func makeDiningViewController() -> DiningViewController {
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
        return diningViewController
    }
    
    private func makeShopViewController() -> ShopViewController {
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
            getUserScreenTimeUseCase: getUserScreenTimeUseCase)
        let shopViewController = ShopViewController(viewModel: viewModel)
        shopViewController.title = "주변상점"
        return shopViewController
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
    private func extractValue(from urlString: String?, value: String) -> String? {
        guard let urlString else {
            return nil
        }
        let components = URLComponents(string: urlString)
        print("components : \(components)")
        print("value: \(components?.queryItems?.first(where: { $0.name == value })?.value)")
        return components?.queryItems?.first(where: { $0.name == value })?.value
    }
}

