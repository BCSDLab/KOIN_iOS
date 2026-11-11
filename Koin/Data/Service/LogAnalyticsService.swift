//
//  LogAnalyticsService.swift
//  koin
//
//  Created by 김나훈 on 5/27/24.
//

import FirebaseAnalytics

protocol LogAnalyticsService {
    func logEvent(label: EventLabelType, value: Any, category: EventParameter.EventCategory?, parameters: [String: String])
}

final class GA4AnalyticsService: LogAnalyticsService {

    func logEvent(label: EventLabelType, value: Any, category: EventParameter.EventCategory?, parameters additionalParameters: [String: String]) {
        let resolvedCategory = category ?? EventParameter.EventCategory(rawValue: label.lastSegment)
        assert(resolvedCategory != nil, "Logging label must end with a category or be called with one: \(label.rawValue)")
        var parameters = makeParameters(label: label.rawValue, category: resolvedCategory?.rawValue ?? label.lastSegment, value: value)
        parameters.merge(additionalParameters) { _, new in new }
        if let screenView = label.screenView { parameters["screen_view"] = screenView }
        guard !label.team.isEmpty else { return }
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
