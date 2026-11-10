//
//  LogAnalyticsService.swift
//  koin
//
//  Created by 김나훈 on 5/27/24.
//

import FirebaseAnalytics

protocol LogAnalyticsService {
    func logEvent(label: EventLabelType, value: Any, category: EventParameter.EventCategory?, parameters: [String: String])
    func logEvent(label: LegacyEventLabelType, category: EventParameter.EventCategory, value: Any)
    func logEvent(label: LegacyEventLabelType, category: EventParameter.EventCategory, value: Any, previousPage: String?, currentPage: String?, durationTime: String?)
    func logEventWithSessionId(label: LegacyEventLabelType, category: EventParameter.EventCategory, value: Any, sessionId: String)
}

final class GA4AnalyticsService: LogAnalyticsService {
    private let sendEvent: (String, [String: Any]) -> Void

    convenience init() {
        self.init(sendEvent: { Analytics.logEvent($0, parameters: $1) })
    }

    init(sendEvent: @escaping (String, [String: Any]) -> Void) {
        self.sendEvent = sendEvent
    }

    func logEvent(label: EventLabelType, value: Any, category: EventParameter.EventCategory?, parameters additionalParameters: [String: String]) {
        let resolvedCategory = category ?? EventParameter.EventCategory(rawValue: label.lastSegment)
        assert(resolvedCategory != nil, "Logging label must end with a category or be called with one: \(label.rawValue)")
        var parameters = makeParameters(label: label.rawValue, category: resolvedCategory?.rawValue ?? label.lastSegment, value: value)
        var reservedKeys: Set<String> = ["event_label", "event_category", "value", "gender", "major", "screen_view", "previous_page", "current_page", "duration_time", "custom_session_id"]
        // 현행 명세에서 custom_session_id는 회원가입(feature=sign_up) 계약에만 있다.
        if label.rawValue.components(separatedBy: "__").dropFirst(2).first == "sign_up" {
            reservedKeys.remove("custom_session_id")
        }
        for (key, value) in additionalParameters where !reservedKeys.contains(key) {
            parameters[key] = value
        }
        if let screenView = label.screenView { parameters["screen_view"] = screenView }
        guard !label.team.isEmpty else { return }
        sendEvent(label.team, parameters)
    }

    func logEvent(label: LegacyEventLabelType, category: EventParameter.EventCategory, value: Any) {
        sendEvent(label.team, makeParameters(label: label.rawValue, category: category.rawValue, value: value))
    }

    func logEvent(label: LegacyEventLabelType, category: EventParameter.EventCategory, value: Any, previousPage: String? = nil, currentPage: String? = nil, durationTime: String? = nil) {
        var defaultParameters = [
            "event_label": label.rawValue,
            "event_category": category.rawValue,
            "value": value,
            "gender": UserDataManager.shared.gender,
            "major": UserDataManager.shared.major
        ]
        
        if let previousPage = previousPage {
            defaultParameters["previous_page"] = previousPage
        }
        
        if let currentPage = currentPage {
            defaultParameters["current_page"] = currentPage
        }
        
        if let durationTime = durationTime {
            defaultParameters["duration_time"] = durationTime
        }
        
        Analytics.logEvent(label.team, parameters: defaultParameters)
    }

    func logEventWithSessionId(label: LegacyEventLabelType, category: EventParameter.EventCategory, value: Any, sessionId: String) {
        let parameters: [String: Any] = [
            "event_label": label.rawValue,
            "event_category": category.rawValue,
            "value": value,
            "custom_session_id": sessionId,
            "gender": UserDataManager.shared.gender,
            "major": UserDataManager.shared.major
        ]

        Analytics.logEvent(label.team, parameters: parameters)
    }

    private func makeParameters(label: String, category: String, value: Any) -> [String: Any] {
        [
            "event_label": label,
            "event_category": category,
            "value": value,
            "gender": UserDataManager.shared.gender,
            "major": UserDataManager.shared.major
        ]
    }
}
