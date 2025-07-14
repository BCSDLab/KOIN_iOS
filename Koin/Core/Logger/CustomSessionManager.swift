//
//  CustomSessionManager.swift
//  koin
//
//  Created by 이은지 on 7/14/25.
//

import Foundation

// 회원가입 커스텀 세션
/// 세션id가 생성되고 15분 동안 세션id를 유지
/// 이후에 다시 생성 이벤트가 발생한다면 새로운 세션id를 생성
struct CustomSessionManager {
    private static let sessionKey = "custom_session_id"
    private static let sessionStartKey = "custom_session_start_time"
    private static let sessionDuration: TimeInterval = 900

    static func getOrCreateSessionId(
        eventName: String = "sign_up",
        userId: Int = 0,
        platform: String = "iOS"
    ) -> String {
        let defaults = UserDefaults.standard
        let now = Date().timeIntervalSince1970

        if let existingSessionId = defaults.string(forKey: sessionKey),
           let startTime = defaults.object(forKey: sessionStartKey) as? TimeInterval,
           now - startTime < sessionDuration {
            return existingSessionId
        }

        let timestamp = Int(now)
        let random = String(UUID().uuidString.filter { $0.isLetter }.prefix(5)).uppercased()
        let sessionId = "\(eventName)_\(userId)_\(platform)_\(timestamp)_\(random)"

        defaults.set(sessionId, forKey: sessionKey)
        defaults.set(now, forKey: sessionStartKey)

        return sessionId
    }
}
