//
//  NotificationService.swift
//  SparkNotificationService
//
//  Created by 김나훈 on 4/3/24.
//

import UserNotifications
import FirebaseMessaging

class NotificationService: UNNotificationServiceExtension {

    var contentHandler: ((UNNotificationContent) -> Void)?
    var bestAttemptContent: UNNotificationContent?

    override func didReceive(
        _ request: UNNotificationRequest,
        withContentHandler contentHandler: @escaping (UNNotificationContent) -> Void
    ) {
        self.contentHandler = contentHandler
        self.bestAttemptContent = request.content
        
        guard let bestAttemptContent = request.content.mutableCopy() as? UNMutableNotificationContent else {
            // 만약 mutableCopy가 UNMutableNotificationContent로 변환되지 않는다면,
            // 바로 이 함수에서 빠져나갑니다.
            contentHandler(request.content)
            return
        }
        
        Task {
            // MARK: - SwiftData에 Notification 데이터를 기록한다.
            do {
                try await saveNotificationIfAvailable(userInfo: bestAttemptContent.userInfo)
            } catch {
                print(error.localizedDescription)
            }
            
            // MARK: - 푸시알림이 이미지를 포함하는 경우 처리
            if let fcmOptionsUserInfo = bestAttemptContent.userInfo["fcm_options"] as? [String: Any],
               let imageURLString = fcmOptionsUserInfo["image"] as? String,
               let imageURL = URL(string: imageURLString),
               let imageData = try? Data(contentsOf: imageURL),
               let attachment = UNNotificationAttachment.saveImageToDisk(identifier: "certificationImage.jpg", data: imageData, options: nil) {
                bestAttemptContent.attachments = [attachment]
            }
            
            contentHandler(bestAttemptContent)
        }
    }
    
    override func serviceExtensionTimeWillExpire() {
        // Called just before the extension will be terminated by the system.
        // Use this as an opportunity to deliver your "best attempt" at modified content, otherwise the original push payload will be used.
        if let contentHandler = contentHandler, let bestAttemptContent =  bestAttemptContent {
            contentHandler(bestAttemptContent)
        }
    }
}

extension NotificationService {
    private func saveNotificationIfAvailable(userInfo: [AnyHashable: Any]) async throws {
        guard let aps = userInfo["aps"] as? [String: Any],
              let alert = aps["alert"] as? [String: Any],
              let body = alert["body"] as? String,
              let title = alert["title"] as? String,
              let category = aps["category"] as? String,
              let appPath = AppPath(rawValue: category),
              let schemeUri = userInfo["schemeUri"] as? String,
              let messageId = userInfo["gcm.message_id"] as? String else {
            throw NotificationHistoryError.parsingError
        }
        
        let notificationRecord = NotificationRecord(
            body: body,
            title: title,
            category: appPath,
            schemeUri: schemeUri,
            messageId: messageId
        )
        
        try await DefaultNotificationHistoryService().insert(record: notificationRecord)
    }
}

extension UNNotificationAttachment {
    static func saveImageToDisk(identifier: String, data: Data, options: [AnyHashable : Any]? = nil) -> UNNotificationAttachment? {
        let fileManager = FileManager.default
        let folderName = ProcessInfo.processInfo.globallyUniqueString
        guard let folderURL = NSURL(fileURLWithPath: NSTemporaryDirectory()).appendingPathComponent(folderName, isDirectory: true) else {
            return nil
        }

        do {
            try fileManager.createDirectory(at: folderURL, withIntermediateDirectories: true, attributes: nil)
            let fileURL = folderURL.appendingPathExtension(identifier)
            try data.write(to: fileURL)
            let attachment = try UNNotificationAttachment(identifier: identifier, url: fileURL, options: options)
            return attachment
        } catch {
            print("saveImageToDisk error - \(error)")
        }
        return nil
    }
    
}
