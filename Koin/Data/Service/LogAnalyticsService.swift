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
}

final class GA4AnalyticsService: LogAnalyticsService {

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
        Analytics.logEvent(label.team, parameters: parameters)
    }

    func logEvent(label: LegacyEventLabelType, category: EventParameter.EventCategory, value: Any) {
        Analytics.logEvent(label.team, parameters: makeParameters(label: label.rawValue, category: category.rawValue, value: value))
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
