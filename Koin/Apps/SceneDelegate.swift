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
    
    // MARK: - cold start & 딥링크
    func scene(
        _ scene: UIScene,
        willConnectTo session: UISceneSession,
        options connectionOptions: UIScene.ConnectionOptions
    ) {
        // cold start
        guard let windowScene = (scene as? UIWindowScene) else { return }
        let window = UIWindow(windowScene: windowScene)
        let navigationController = CustomNavigationController(rootViewController: makeHomeViewController())
        window.rootViewController = navigationController
        self.window = window
        window.makeKeyAndVisible()
        
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
            let shopViewController = createShopViewController()
            navigationController?.pushViewController(shopViewController, animated: true)
        case .dining:
            let diningViewController = createDiningViewController()
            navigationController?.pushViewController(diningViewController, animated: true)
        case .timeTable:
            let timeTableViewController = createTimeTableViewController()
            navigationController?.pushViewController(timeTableViewController, animated: true)
        case .keyword:
            guard let id = extractValue(from: schemeUri, value: "id"), let intId = Int(id) else {
                print("noticeId : Invalid or missing")
                return
            }
            let noticeDataViewController = createNoticeDataViewController(noticeId: intId)
            navigationController?.pushViewController(noticeDataViewController, animated: true)
            
            DefaultLogAnalyticsEventUseCase(
                repository: GA4AnalyticsRepository(service: GA4AnalyticsService())
            ).execute(
                label: EventParameter.EventLabel.Campus.keywordNotification,
                category: .notification,
                value: category.rawValue
            )
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
            let callVanDataViewController = createCallVanDataViewController(postId: intPostId)
            navigationController?.pushViewController(callVanDataViewController, animated: true)
        case .callvanChat:
            guard let postId = extractValue(from: schemeUri, value: "postId"), let intPostId = Int(postId) else {
                print("postId : Invalid or missing")
                return
            }
            let callVanChatViewController = createCallVanChatViewController(postId: intPostId)
            navigationController?.pushViewController(callVanChatViewController, animated: true)
        }
    }
}

extension SceneDelegate {
    
    private func makeHomeViewController() -> UIViewController {
        let diningRepository = DefaultDiningRepository(diningService: DefaultDiningService(), shareService: KakaoShareService())
        let shopRepository = DefaultShopRepository(service: DefaultShopService())
        let fetchDiningListUseCase = DefaultFetchDiningListUseCase(diningRepository: diningRepository)
        let fetchShopCategoryUseCase = DefaultFetchShopCategoryListUseCase(shopRepository: shopRepository)
        let logAnalyticsEventUseCase = DefaultLogAnalyticsEventUseCase(repository: GA4AnalyticsRepository(service: GA4AnalyticsService()))
        let fetchHotNoticeArticlesUseCase = DefaultFetchHotNoticeArticlesUseCase(noticeListRepository: DefaultNoticeListRepository(service: DefaultNoticeService()))
        let getUserScreenTimeUseCase = DefaultGetUserScreenTimeUseCase()
        let dateProvider = DefaultDateProvider()
        let checkLoginUseCase = DefaultCheckLoginUseCase(userRepository: DefaultUserRepository(service: DefaultUserService()))
        let fetchLostItemStatsUseCase = DefaultFetchLostItemStatsUseCase(repository: DefaultLostItemRepository(service: DefaultLostItemService()))
        
        let homeViewModel = HomeViewModel(
            fetchDiningListUseCase: fetchDiningListUseCase,
            logAnalyticsEventUseCase: logAnalyticsEventUseCase,
            getUserScreenTimeUseCase: getUserScreenTimeUseCase,
            fetchHotNoticeArticlesUseCase: fetchHotNoticeArticlesUseCase,
            fetchShopCategoryListUseCase: fetchShopCategoryUseCase,
            dateProvider: dateProvider,
            checkVersionUseCase: DefaultCheckVersionUseCase(coreRepository: DefaultCoreRepository(service: DefaultCoreService())),
            fetchKeywordNoticePhraseUseCase: DefaultFetchKeywordNoticePhraseUseCase(),
            checkLoginUseCase: checkLoginUseCase,
            fetchLostItemStatsUseCase: fetchLostItemStatsUseCase
        )
        let viewController = HomeViewController(viewModel: homeViewModel)
        return viewController
    }
    
    @objc private func presentErrorViewController() {
        
        guard isPresentingErrorViewController == false else {
            return
        }
        
        if let navigationController = window?.rootViewController as? CustomNavigationController {
            
            let homeViewController = makeHomeViewController()
            let completion: ()->Void = { [weak self] in
                navigationController.setViewControllers([homeViewController], animated: false)
                navigationController.dismiss(animated: true) {
                    self?.isPresentingErrorViewController = false
                }
            }
            let errorViewController = ErrorViewController(completion: completion).then {
                $0.modalPresentationStyle = .fullScreen
            }
            
            DispatchQueue.main.async {
                if let _ = navigationController.presentedViewController {
                    navigationController.dismiss(animated: true) {
                        navigationController.present(errorViewController, animated: true)
                    }
                } else {
                    navigationController.present(errorViewController, animated: true)
                }
            }
            isPresentingErrorViewController = true
        }
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
    
    private func createCallVanDataViewController(postId: Int) -> CallVanDataViewController {
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
    
    private func createCallVanChatViewController(postId: Int) -> CallVanChatViewController {
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

    private func createNoticeDataViewController(noticeId: Int) -> NoticeDataViewController {
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
    
    private func createDiningViewController() -> DiningViewController {
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
    
    private func createShopViewController() -> ShopViewController {
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
    
    private func createTimeTableViewController() -> TimetableViewController {
        let viewController = TimetableViewController(viewModel: TimetableViewModel())
        return viewController
    }
    
    private func handleLostItemNavigation(navigationController: UINavigationController?) {
        let userRepository = DefaultUserRepository(service: DefaultUserService())
        let lostItemRepository = DefaultLostItemRepository(service: DefaultLostItemService())
        let checkLoginUseCase = DefaultCheckLoginUseCase(userRepository: userRepository)
        let fetchLostItemItemUseCase = DefaultFetchLostItemListUseCase(repository: lostItemRepository)
        let logAnalyticsEventUseCase = DefaultLogAnalyticsEventUseCase(repository: GA4AnalyticsRepository(service: GA4AnalyticsService()))
        let viewModel = LostItemListViewModel(
            checkLoginUseCase: checkLoginUseCase,
            fetchLostItemListUseCase: fetchLostItemItemUseCase,
            logAnalyticsEventUseCase: logAnalyticsEventUseCase
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
