//
//  CustomSessionManager.swift
//  koin
//
//  Created by 이은지 on 7/14/25.
//

import Foundation

// 커스텀 세션 로깅
/// 15분 또는 30분 동안 세션 ID를 유지
/// 유지 시간이 지나면 새로운 세션 ID를 생성
struct CustomSessionManager {
    private static let sessionKey = "custom_session_id"
    private static let sessionStartKey = "custom_session_start_time"
    private static let sessionDurationKey = "custom_session_duration"
    private static let sessionEventNameKey = "custom_session_event_name"

    enum Duration: TimeInterval {
        case fifteenMinutes = 900   // 15분
        case thirtyMinutes = 1800   // 30분
    }

    static func getOrCreateSessionId(
        duration: Duration = .fifteenMinutes,
        eventName: String = "sign_up",
        loginStatus: Int? = nil,
        platform: String = "iOS"
    ) -> String {
        let defaults = UserDefaults.standard
        let now = Date().timeIntervalSince1970

        let savedDuration = defaults.double(forKey: sessionDurationKey)
        let savedEventName = defaults.string(forKey: sessionEventNameKey)

        if let existingSessionId = defaults.string(forKey: sessionKey),
           let startTime = defaults.object(forKey: sessionStartKey) as? TimeInterval,
           now - startTime < savedDuration,
           savedDuration == duration.rawValue,
           savedEventName == eventName {
            return existingSessionId
        }

        let timestamp = Int(now)
        let random = String(UUID().uuidString.filter { $0.isLetter }.prefix(5)).uppercased()
        let loginFlag = loginStatus ?? loginStatusFlag()
        let sessionId = "\(eventName)_\(loginFlag)_\(platform)_\(timestamp)_\(random)"

        defaults.set(sessionId, forKey: sessionKey)
        defaults.set(now, forKey: sessionStartKey)
        defaults.set(duration.rawValue, forKey: sessionDurationKey)
        defaults.set(eventName, forKey: sessionEventNameKey)

        return sessionId
    }

    private static func loginStatusFlag() -> Int {
        if let token = KeychainWorker.shared.read(key: .access),
               token.isEmpty == false {
            return 1
        } else {
            return 0
        }
    }
}
