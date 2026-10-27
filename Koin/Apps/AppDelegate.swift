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
    
    // MARK: - 푸시알림 Warm Start & Cold Start (optional)
    func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        didReceive response: UNNotificationResponse,
        withCompletionHandler completionHandler: @escaping () -> Void
    ) {
        let sceneDelegate = response.targetScene?.delegate as? SceneDelegate
        let userInfo = response.notification.request.content.userInfo
        
        sceneDelegate?.handleNotificationData(userInfo: userInfo)
        completionHandler()
    }
    
    // MARK: - 앱 시작시 초기화 메서드
    func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
    ) -> Bool {
        
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
    
    // MARK: - APNs 토큰 처리
    func application(
        _ application: UIApplication,
        didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data
    ) {
        Messaging.messaging().apnsToken = deviceToken
    }
    
    // MARK: - Foreground에서 푸시알림 옵션
    func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        willPresent notification: UNNotification
    ) async -> UNNotificationPresentationOptions {
        // 푸시 알림 도착 전역에 알림 (HomeTabbar에서 관찰)
        NotificationCenter.default.post(
            name: NSNotification.Name("Notification Sent"),
            object: nil
        )
        // 현재 보고 있는 채팅방의 푸시는 묵살
        if await shouldSuppressForegroundNotification(userInfo: notification.request.content.userInfo) {
            return []
        }
        // 푸시 알림 옵션 반환
        return [[.banner, .list, .sound]]
    }
    
    // MARK: UISceneSession Lifecycle
    func application(
        _ application: UIApplication,
        configurationForConnecting connectingSceneSession: UISceneSession,
        options: UIScene.ConnectionOptions
    ) -> UISceneConfiguration {
        return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }
}

extension AppDelegate: MessagingDelegate {
    
    // MARK: - FCM 토큰 처리
    func messaging(
        _ messaging: Messaging,
        didReceiveRegistrationToken fcmToken: String?
    ) {
        guard let fcmToken = fcmToken else { return }
        KeychainWorker.shared.create(key: .fcm, token: fcmToken)
    }
}

// MARK: - Foreground 채팅 푸시 묵살 여부
/// 채팅 중 푸시알림이 계속 도착하는 것을 방지한다. 채팅 수정 예정이므로 임시구현한다.
extension AppDelegate {
    private func shouldSuppressForegroundNotification(userInfo: [AnyHashable: Any]) async -> Bool {
        guard let sceneDelegate = UIApplication.shared.connectedScenes.first?.delegate as? SceneDelegate,
              let topViewController = sceneDelegate.navigationController?.topViewController else {
            return false
        }
        
        // 팀원모집 채팅
        if let type = userInfo["type"] as? String,
           RecruitNotificationType(rawValue: type) == .newChatMessage {
            guard let recruitChatViewController = topViewController as? RecruitChatViewController,
                  let notificationId = Int(userInfo["notification_id"] as? String) else {
                return false
            }
            // 푸시에 채팅방 정보가 없으므로 알림 목록에서 notificationId 로 조회한다.
            let fetchRecruitNotificationListUseCase = DefaultFetchRecruitNotificationListUseCase(
                repository: DefaultRecruitRepository(service: DefaultRecruitService())
            )
            guard let notificationList = try? await fetchRecruitNotificationListUseCase.execute(page: 1),
                  let notification = notificationList.notifications.first(where: { $0.id == notificationId }),
                  sceneDelegate.navigationController?.topViewController === recruitChatViewController else {
                return false
            }
            // RecruitNotificationListViewController 의 채팅방 진입 규칙과 동일하게 비교한다.
            switch recruitChatViewController.roomSource {
            case let .direct(recruitmentId, applicationId):
                return notification.recruitmentId == recruitmentId
                && notification.applicationId == applicationId
            case let .team(recruitmentId, chatRoomId):
                return notification.recruitmentId == recruitmentId
                && notification.applicationId == nil
                && notification.chatRoomId == chatRoomId
            }
        }
        
        // 분실물 채팅, 콜밴 채팅
        guard let aps = userInfo["aps"] as? [String: AnyObject],
              let category = aps["category"] as? String,
              let appPath = AppPath(rawValue: category),
              let schemeUri = userInfo["schemeUri"] as? String,
              let queryItems = URLComponents(string: schemeUri)?.queryItems else {
            return false
        }
        let query = queryItems.reduce(into: [String: String]()) { result, item in
            result[item.name] = item.value
        }
        
        switch appPath {
        case .chat:
            guard let lostItemChatViewController = topViewController as? LostItemChatViewController,
                  let chatRoomId = Int(query["chatRoomId"]) else {
                return false
            }
            return lostItemChatViewController.chatRoomId == chatRoomId
        case .callvanChat:
            guard let callVanChatViewController = topViewController as? CallVanChatViewController,
                  let postId = Int(query["postId"]) else {
                return false
            }
            return callVanChatViewController.postId == postId
        default:
            return false
        }
    }
}
