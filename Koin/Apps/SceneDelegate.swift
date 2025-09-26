//
//  SceneDelegate.swift
//  Koin
//
//  Created by 김나훈 on 1/14/24.
//

import UIKit

class SceneDelegate: UIResponder, UIWindowSceneDelegate {
    
    var window: UIWindow?
    var urlParameters: [String: String]?
    
    func scene(_ scene: UIScene,
               willConnectTo session: UISceneSession,
               options connectionOptions: UIScene.ConnectionOptions) {
        guard let windowScene = (scene as? UIWindowScene) else { return }
        let window = UIWindow(windowScene: windowScene)
        
        let navigationController = CustomNavigationController(rootViewController: makeHomeViewController())
        window.rootViewController = navigationController
        self.window = window
        window.makeKeyAndVisible()
        
        if let userActivity = connectionOptions.userActivities.first(where: { $0.activityType == NSUserActivityTypeBrowsingWeb }),
                   let incomingURL = userActivity.webpageURL {
                    handleIncomingDeepLink(url: incomingURL, navigationController: navigationController)
                } else if let urlContext = connectionOptions.urlContexts.first {
                    handleIncomingDeepLink(url: urlContext.url, navigationController: navigationController)
                }
    }
    private func handleIncomingDeepLink(url: URL, navigationController: UINavigationController) {
            // URL 경로가 "/articles/lost-item"인 경우에 처리
            if url.path == "/articles/lost-item" {
                let noticeRepository = DefaultNoticeListRepository(service: DefaultNoticeService())
                let viewController = NoticeListViewController(viewModel: NoticeListViewModel(
                    fetchNoticeArticlesUseCase: DefaultFetchNoticeArticlesUseCase(noticeListRepository: noticeRepository),
                    fetchMyKeywordUseCase: DefaultFetchNotificationKeywordUseCase(noticeListRepository: noticeRepository),
                    logAnalyticsEventUseCase: DefaultLogAnalyticsEventUseCase(repository: GA4AnalyticsRepository(service: GA4AnalyticsService())),
                    noticeListType: .lostItem
                ))
                navigationController.pushViewController(viewController, animated: false)
            }
            // 다른 딥링크 처리 로직을 추가할 수 있습니다.
        }
    func scene(_ scene: UIScene, continue userActivity: NSUserActivity) {
        guard userActivity.activityType == NSUserActivityTypeBrowsingWeb,
               let incomingURL = userActivity.webpageURL else { return }
         
         // URL의 경로가 "/articles/lost-item"인지 확인
         if incomingURL.path == "/articles/lost-item" {
                if let navigationController = window?.rootViewController as? UINavigationController {
                    let noticeRepository = DefaultNoticeListRepository(service: DefaultNoticeService())
                    let viewController = NoticeListViewController(viewModel: NoticeListViewModel(fetchNoticeArticlesUseCase: DefaultFetchNoticeArticlesUseCase(noticeListRepository: noticeRepository), fetchMyKeywordUseCase: DefaultFetchNotificationKeywordUseCase(noticeListRepository: noticeRepository), logAnalyticsEventUseCase: DefaultLogAnalyticsEventUseCase(repository: GA4AnalyticsRepository(service: GA4AnalyticsService())), noticeListType: .lostItem))
                
                    navigationController.pushViewController(viewController, animated: false)
                       }
                // 네비게이션 컨트롤러를 통해 LostItemViewController로 이동
              
            }
    }
    
    func scene(_ scene: UIScene, openURLContexts URLContexts: Set<UIOpenURLContext>) {
        guard let urlContext = URLContexts.first else { return }
        NotificationHandler.shared.handleIncomingURL(url: urlContext.url, rootViewController: window?.rootViewController)
    }
    
    func scene(_ scene: UIScene, didReceive notificationResponse: UNNotificationResponse) {
        let userInfo = notificationResponse.notification.request.content.userInfo
        if let rootViewController = window?.rootViewController as? UINavigationController {
            NotificationHandler.shared.handleNotificationData(userInfo: userInfo, rootViewController: rootViewController)
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
        
        let homeViewModel = HomeViewModel(
            fetchDiningListUseCase: fetchDiningListUseCase,
            logAnalyticsEventUseCase: logAnalyticsEventUseCase,
            getUserScreenTimeUseCase: getUserScreenTimeUseCase,
            fetchHotNoticeArticlesUseCase: fetchHotNoticeArticlesUseCase,
            fetchShopCategoryListUseCase: fetchShopCategoryUseCase,
            dateProvider: dateProvider,
            checkVersionUseCase: DefaultCheckVersionUseCase(coreRepository: DefaultCoreRepository(service: DefaultCoreService())),
            assignAbTestUseCase: DefaultAssignAbTestUseCase(abTestRepository: DefaultAbTestRepository(service: DefaultAbTestService())),
            fetchKeywordNoticePhraseUseCase: DefaultFetchKeywordNoticePhraseUseCase(),
            checkLoginUseCase: checkLoginUseCase
        )
        let viewController = HomeViewController(viewModel: homeViewModel)
        return viewController
    }
    
    
}
