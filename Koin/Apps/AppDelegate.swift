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
    var sceneDelegate: SceneDelegate? {
        let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene
        return windowScene?.delegate as? SceneDelegate
    }

    // MARK: - 푸시알림을 탭했을 때의 동작 구현
    func userNotificationCenter(_ center: UNUserNotificationCenter,
                                didReceive response: UNNotificationResponse,
                                withCompletionHandler completionHandler: @escaping () -> Void) {
        let userInfo = response.notification.request.content.userInfo
        sceneDelegate?.handleNotificationData(userInfo: userInfo)
        completionHandler()
    }
    
    // MARK: - 앱 시작시 초기화 메서드
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        KakaoSDK.initSDK(appKey: Bundle.main.kakaoApiKey)
        
        FirebaseApp.configure()
        let center = UNUserNotificationCenter.current()
        center.delegate = self
        center.requestAuthorization(options: [.alert, .badge, .sound]) { granted, error in
        }
        
        application.registerForRemoteNotifications()
        
        Messaging.messaging().delegate = self
        
        SwiftRater.daysUntilPrompt = 7
        SwiftRater.significantUsesUntilPrompt = 10
        //SwiftRater.debugMode = true
        SwiftRater.appLaunched()
        
        return true
    }
    
    // MARK: - APNS 토큰 처리
    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        Messaging.messaging().apnsToken = deviceToken
    }
    
    // MARK: - Foreground에서 푸시알림 옵션
    func userNotificationCenter(_ center: UNUserNotificationCenter,
                                willPresent notification: UNNotification) async
    -> UNNotificationPresentationOptions {
        // 푸시 알림 옵션 반환
        return [[.banner, .list, .sound]]
    }
    
    // MARK: UISceneSession Lifecycle
    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }
}

extension AppDelegate: MessagingDelegate {
    
    // MARK: - FCM 토큰 처리
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
