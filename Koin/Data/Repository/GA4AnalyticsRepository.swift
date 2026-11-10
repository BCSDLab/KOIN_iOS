//
//  GA4AnalyticsRepository.swift
//  koin
//
//  Created by 김나훈 on 5/27/24.
//

final class GA4AnalyticsRepository: AnalyticsRepository {
    
    private let service: LogAnalyticsService
    
    init(service: LogAnalyticsService) {
        self.service = service
    }
    func logEvent(label: EventLabelType, value: Any, category: EventParameter.EventCategory?, parameters: [String: String]) {
        service.logEvent(label: label, value: value, category: category, parameters: parameters)
    }

    func logEvent(label: LegacyEventLabelType, category: EventParameter.EventCategory, value: Any) {
        service.logEvent(label: label, category: category, value: value)
    }

    func logEvent(label: LegacyEventLabelType, category: EventParameter.EventCategory, value: Any, previousPage: String?, currentPage: String?, durationTime: String?) {
        service.logEvent(label: label, category: category, value: value, previousPage: previousPage, currentPage: currentPage, durationTime: durationTime)
    }

    func logEventWithSessionId(label: LegacyEventLabelType, category: EventParameter.EventCategory, value: Any, sessionId: String) {
        service.logEventWithSessionId(label: label, category: category, value: value, sessionId: sessionId)
    }
}
