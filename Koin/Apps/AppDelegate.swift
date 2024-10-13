//
//  AppDelegate.swift
//  Koin
//
//  Created by 김나훈 on 1/14/24.
//
import Firebase
import KakaoSDKCommon
import UIKit
import UserNotifications


@main
class AppDelegate: UIResponder, UIApplicationDelegate, UNUserNotificationCenterDelegate {
    
    func application(_ app: UIApplication, open url: URL, options: [UIApplication.OpenURLOptionsKey : Any] = [:]) -> Bool {
        guard let components = NSURLComponents(url: url, resolvingAgainstBaseURL: true), let path = components.path, let params = components.queryItems else { return false }
        if path == "KEYWORD" {
            if let noticeId = params.first?.value {
                navigateToNoticeData(noticeId: Int(noticeId) ?? 0)
                return true
            }
            else {
                return false
            }
        }
        return false
    }
    
    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        let userInfo = response.notification.request.content.userInfo
        let application = UIApplication.shared
        
        //앱이 켜져있는 상태에서 푸쉬 알림을 눌렀을 때
        if application.applicationState == .active || application.applicationState == .inactive || application.applicationState == .background {
            if let aps = userInfo["aps"] as? [String: AnyObject], let category = aps["category"] as? String {
                navigateToScene(category: category)
            }
            completionHandler()
        }
    }
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        KakaoSDK.initSDK(appKey: Bundle.main.kakaoApiKey)
        let appearance = UINavigationBarAppearance()
        appearance.configureWithOpaqueBackground()
        appearance.backgroundColor = UIColor.appColor(.primary500)
        
        let font = UIFont.appFont(.pretendardMedium, size: 20)
        let titleAttribute = [
            NSAttributedString.Key.font: font,
            NSAttributedString.Key.foregroundColor: UIColor.white
        ]
        appearance.titleTextAttributes = titleAttribute
        appearance.largeTitleTextAttributes = titleAttribute
        UINavigationBar.appearance().standardAppearance = appearance
        UINavigationBar.appearance().scrollEdgeAppearance = appearance
        UINavigationBar.appearance().compactAppearance = appearance
        UINavigationBar.appearance().tintColor = UIColor.appColor(.neutral0)
        FirebaseApp.configure()
        
        
        let center = UNUserNotificationCenter.current()
        center.delegate = self
        center.requestAuthorization(options: [.alert, .badge, .sound]) { granted, error in
        }
        
        application.registerForRemoteNotifications()
        
        Messaging.messaging().delegate = self
        if let notification = launchOptions?[.remoteNotification] as? [String:AnyObject] {
            if let aps = notification["aps"] as? [String: AnyObject], let category = aps["category"] as? String {
                navigateToScene(category: category)
            }
        }
        
        return true
    }
    
    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        print("APNs token received: \(deviceToken)")
        Messaging.messaging().apnsToken = deviceToken
    }
    func userNotificationCenter(_ center: UNUserNotificationCenter,
                                willPresent notification: UNNotification) async
    -> UNNotificationPresentationOptions {
        // 푸시 알림 데이터가 userInfo에 담겨있다.
        let userInfo = notification.request.content.userInfo
        print(userInfo)
        
        // 푸시 알림 옵션 반환
        return [[.banner, .list, .sound]]
    }
    
    
    // MARK: UISceneSession Lifecycle
    
    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }
    
}
extension AppDelegate {
    
    func application(application: UIApplication,
                     didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        Messaging.messaging().apnsToken = deviceToken
    }
    func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable: Any]) async -> UIBackgroundFetchResult {
        print(userInfo)
        
        return UIBackgroundFetchResult.newData
    }
    
}

extension AppDelegate: MessagingDelegate {
    
    func messaging(_ messaging: Messaging, didReceiveRegistrationToken fcmToken: String?) {
        guard let fcmToken = fcmToken else { return }
        
        KeyChainWorker.shared.create(key: .fcm, token: fcmToken)
        
        let dataDict: [String: String] = ["token": fcmToken]
        NotificationCenter.default.post(
            name: Notification.Name("FCMToken"),
            object: nil,
            userInfo: dataDict
        )
    }
}

extension AppDelegate {
    func navigateToNoticeData(noticeId: Int) {
        let currentVc = UIApplication.topViewController()
        let service = DefaultNoticeService()
        let repository = DefaultNoticeListRepository(service: service)
        let logAnalyticsEventUseCase = DefaultLogAnalyticsEventUseCase(repository: GA4AnalyticsRepository(service: GA4AnalyticsService()))
        let viewModel = NoticeDataViewModel(fetchNoticeDataUseCase: DefaultFetchNoticeDataUseCase(noticeListRepository: repository), fetchHotNoticeArticlesUseCase: DefaultFetchHotNoticeArticlesUseCase(noticeListRepository: repository), downloadNoticeAttachmentUseCase: DefaultDownloadNoticeAttachmentsUseCase(noticeRepository: repository), logAnalyticsEventUseCase: logAnalyticsEventUseCase, noticeId: noticeId)
        let vc = NoticeDataViewController(viewModel: viewModel)
        currentVc?.navigationController?.pushViewController(vc, animated: true)
    }
    func navigateToScene(category: String) {
        if category == "dining" {
            let currentVc = UIApplication.topViewController()
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
            currentVc?.navigationController?.pushViewController(diningViewController, animated: true)
        }
        else if category == "shop" {
            let currentVc = UIApplication.topViewController()
            let shopService = DefaultShopService()
            let shopRepository = DefaultShopRepository(service: shopService)
            
            let fetchShopListUseCase = DefaultFetchShopListUseCase(shopRepository: shopRepository)
            let fetchEventListUseCase = DefaultFetchEventListUseCase(shopRepository: shopRepository)
            let fetchShopCategoryListUseCase = DefaultFetchShopCategoryListUseCase(shopRepository: shopRepository)
            let searchShopUseCase = DefaultSearchShopUseCase(shopRepository: shopRepository)
            let logAnalyticsEventUseCase = DefaultLogAnalyticsEventUseCase(repository: GA4AnalyticsRepository(service: GA4AnalyticsService()))
            let getUserScreenTimeUseCase = DefaultGetUserScreenTimeUseCase()
            
            let viewModel = ShopViewModel(
                fetchShopListUseCase: fetchShopListUseCase,
                fetchEventListUseCase: fetchEventListUseCase,
                fetchShopCategoryListUseCase: fetchShopCategoryListUseCase, searchShopUseCase: searchShopUseCase,
                logAnalyticsEventUseCase: logAnalyticsEventUseCase, getUserScreenTimeUseCase: getUserScreenTimeUseCase,
                selectedId: 0
            )
            let movingVc = ShopViewController(viewModel: viewModel)
            movingVc.title = "주변상점"
            currentVc?.navigationController?.pushViewController(movingVc, animated: true)
        }
        else {
            print("Category is not available")
        }
        
    }
}
