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

        let originalBody = bestAttemptContent.body

        self.bestAttemptContent = modifyBodyIfNeeded(of: bestAttemptContent)

        Task {
            // MARK: - SwiftData에 Notification 데이터를 기록한다.
            do {
                try await saveNotificationIfAvailable(content: bestAttemptContent)
            } catch {
                print(error.localizedDescription)
            }
            
            // MARK: - 푸시알림이 이미지를 포함하는 경우 처리
            if let imageURL = imageURL(fromFCMOptions: bestAttemptContent.userInfo) ?? imageURL(fromBody: originalBody),
               let imageData = await downloadImage(from: imageURL),
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
    // MARK: - 채팅 이미지 메시지의 경우 body에 이미지 URL이 담겨오므로 치환한다.
    private func modifyBodyIfNeeded(of content: UNMutableNotificationContent) -> UNMutableNotificationContent {
        if content.body.contains("static.koreatech.in") {
            content.body = "사진을 보냈습니다."
        }
        return content
    }
    
    // MARK: - fcm_options에 담긴 이미지 URL을 꺼낸다.
    private func imageURL(fromFCMOptions userInfo: [AnyHashable: Any]) -> URL? {
        guard let fcmOptionsUserInfo = userInfo["fcm_options"] as? [String: Any],
              let imageURLString = fcmOptionsUserInfo["image"] as? String else {
            return nil
        }
        return URL(string: imageURLString)
    }
    
    // MARK: - String 타입 ImageUrl을 URL 타입으로 변환한다.
    private func imageURL(fromBody body: String) -> URL? {
        guard body.contains("static.koreatech.in") else {
            return nil
        }
        return URL(string: body.trimmingCharacters(in: .whitespacesAndNewlines))
    }
    
    // MARK: - 이미지를 다운로드한다.
    private func downloadImage(from url: URL) async -> Data? {
        return try? await URLSession.shared.data(from: url).0
    }

    private func saveNotificationIfAvailable(content: UNNotificationContent) async throws {
        let userInfo = content.userInfo
        let body = content.body
        let title = content.title
        guard let aps = userInfo["aps"] as? [String: Any],
              aps["alert"] is [String: Any],
              let category = aps["category"] as? String,
              let appPath = AppPath(rawValue: category),
              let schemeUri = userInfo["schemeUri"] as? String,
              let messageId = userInfo["gcm.message_id"] as? String else {
            throw NotificationHistoryError.parsingError
        }
        
        let notificationRecord = NotificationHistoryRecord(
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
