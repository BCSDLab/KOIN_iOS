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
import SwiftRater


@main
class AppDelegate: UIResponder, UIApplicationDelegate, UNUserNotificationCenterDelegate {
    var window: UIWindow?
    
    
    func application(_ app: UIApplication, open url: URL, options: [UIApplication.OpenURLOptionsKey: Any] = [:]) -> Bool {
        guard let components = URLComponents(url: url, resolvingAgainstBaseURL: true),
              let params = components.queryItems else { return false }
        
        let path = components.path
        
        if path == "keyword", let noticeId = params.first(where: { $0.name == "id" })?.value, let intId = Int(noticeId) {
            if let rootViewController = UIApplication.topViewController() as? UINavigationController {
                NotificationHandler.shared.handleNotificationData(
                    userInfo: ["id": "\(intId)"],
                    rootViewController: rootViewController
                )
            }
            return true
        }
        return false
    }
    
    
    func userNotificationCenter(_ center: UNUserNotificationCenter,
                                didReceive response: UNNotificationResponse,
                                withCompletionHandler completionHandler: @escaping () -> Void) {
        let userInfo = response.notification.request.content.userInfo
        let application = UIApplication.shared
        
        if application.applicationState == .active || application.applicationState == .inactive || application.applicationState == .background {
            
            if let rootViewController = UIApplication.shared.connectedScenes
                .compactMap({ $0 as? UIWindowScene })
                .first?
                .windows
                .first(where: { $0.isKeyWindow })?
                .rootViewController as? CustomNavigationController {
                NotificationHandler.shared.handleNotificationData(userInfo: userInfo, rootViewController: rootViewController)
            }
            
            
            completionHandler()
        }
    }
    
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        KakaoSDK.initSDK(appKey: Bundle.main.kakaoApiKey)
        
        FirebaseApp.configure()
        let center = UNUserNotificationCenter.current()
        center.delegate = self
        center.requestAuthorization(options: [.alert, .badge, .sound]) { granted, error in
        }
        
        application.registerForRemoteNotifications()
        
        Messaging.messaging().delegate = self
        if let notification = launchOptions?[.remoteNotification] as? [AnyHashable: Any],
           let rootViewController = window?.rootViewController as? UINavigationController {
            NotificationHandler.shared.handleNotificationData(userInfo: notification, rootViewController: rootViewController)
        }
        
        SwiftRater.daysUntilPrompt = 7
        SwiftRater.significantUsesUntilPrompt = 10
        //SwiftRater.debugMode = true
        SwiftRater.appLaunched()
        
        return true
    }
    
    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        Messaging.messaging().apnsToken = deviceToken
    }
    func userNotificationCenter(_ center: UNUserNotificationCenter,
                                willPresent notification: UNNotification) async
    -> UNNotificationPresentationOptions {
        // 푸시 알림 데이터가 userInfo에 담겨있다.
        let userInfo = notification.request.content.userInfo
        
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
        if let rootViewController = window?.rootViewController as? UINavigationController {
            NotificationHandler.shared.handleNotificationData(userInfo: userInfo, rootViewController: rootViewController)
        }
        return .newData
    }
    func messaging(_ messaging: Messaging, didReceiveRegistrationToken fcmToken: String?) {
        guard let fcmToken = fcmToken else { return }
        
        KeychainWorker.shared.create(key: .fcm, token: fcmToken)
        
        let dataDict: [String: String] = ["token": fcmToken]
        NotificationCenter.default.post(
            name: Notification.Name("FCMToken"),
            object: nil,
            userInfo: dataDict
        )
    }
}

extension AppDelegate: MessagingDelegate {
    
 
}

