//
//  MockAnalyticesService.swift
//  koin
//
//  Created by 김나훈 on 6/11/24.
//

import Foundation

final class MockAnalyticsService: LogAnalyticsService {
    func logEvent(label: EventLabelType, value: Any, category: EventParameter.EventCategory?, parameters: [String: String]) {
        debugPrint("\(label) \(value) \(String(describing: category)) \(parameters)")
    }

    func logEvent(label: LegacyEventLabelType, category: EventParameter.EventCategory, value: Any) {
        debugPrint("\(label) \(category) \(value)")
    }

    func logEvent(label: LegacyEventLabelType, category: EventParameter.EventCategory, value: Any, previousPage: String?, currentPage: String?, durationTime: String?) {
        debugPrint("\(label) \(category) \(value) \(previousPage ?? "") \(currentPage ?? "") \(durationTime ?? "")")
    }

    func logEventWithSessionId(label: LegacyEventLabelType, category: EventParameter.EventCategory, value: Any, sessionId: String) {
        debugPrint("\(label) \(category) \(value) \(sessionId)")
    }
}
