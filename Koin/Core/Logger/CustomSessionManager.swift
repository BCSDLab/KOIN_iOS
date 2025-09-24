//
//  CustomSessionManager.swift
//  koin
//
//  Created by 이은지 on 7/14/25.
//

import Foundation

/// 커스텀 세션 로깅 매니저
/// [세션이름]_[로그인0/1]_[플랫폼]_[세션시작(UnixTs)]_[랜덤5]
/// 예) sign_up_0_WEB_1758713295_SDAFS
struct CustomSessionManager {

    private struct Keys {
        let id: String
        let startedAt: String
        let duration: String
        let event: String
        let loginFlag: String
        let platform: String

        init(eventName: String) {
            let base = "custom_session.\(eventName)"
            id = "\(base).id"
            startedAt = "\(base).startedAt"
            duration = "\(base).duration"
            event = "\(base).event"
            loginFlag = "\(base).loginFlag"
            platform = "\(base).platform"
        }
    }

    enum Duration: TimeInterval {
        case fifteenMinutes = 900
        case thirtyMinutes  = 1800
    }

    /// 생성 및 이전 세션 재사용
    static func getOrCreateSessionId(duration: Duration = .fifteenMinutes, eventName: String, loginStatus: Int? = nil, platform: String = "iOS") -> String {
        let keys = Keys(eventName: eventName)
        let defaults = UserDefaults.standard

        let now = Date().timeIntervalSince1970
        let savedEvent = defaults.string(forKey: keys.event)
        let savedId = defaults.string(forKey: keys.id)
        let savedStart = defaults.double(forKey: keys.startedAt)
        let savedDuration = defaults.double(forKey: keys.duration)

        if let existing = savedId,
           savedEvent == eventName,
           savedStart > 0,
           now - savedStart < savedDuration {
            return existing
        }

        let timeStamp = Int(now)
        let randomString = String(UUID().uuidString.filter { $0.isLetter }.prefix(5)).uppercased()
        let flag = loginStatus ?? defaults.integer(forKey: "loginFlag")

        let newId = "\(eventName)_\(flag)_\(platform)_\(timeStamp)_\(randomString)"

        defaults.set(newId, forKey: keys.id)
        defaults.set(now, forKey: keys.startedAt)
        defaults.set(duration.rawValue, forKey: keys.duration)
        defaults.set(eventName, forKey: keys.event)
        defaults.set(flag, forKey: keys.loginFlag)
        defaults.set(platform, forKey: keys.platform)

        return newId
    }

    /// 현재 세션 조회
    static func current(eventName: String) -> String? {
        UserDefaults.standard.string(forKey: Keys(eventName: eventName).id)
    }

    /// 세션 이탈
    static func end(eventName: String) {
        let keys = Keys(eventName: eventName)
        let defaults = UserDefaults.standard
        defaults.removeObject(forKey: keys.id)
        defaults.removeObject(forKey: keys.startedAt)
        defaults.removeObject(forKey: keys.duration)
        defaults.removeObject(forKey: keys.event)
        defaults.removeObject(forKey: keys.loginFlag)
        defaults.removeObject(forKey: keys.platform)
    }
}
