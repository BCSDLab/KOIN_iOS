//
//  MockAnalyticesService.swift
//  koin
//
//  Created by 김나훈 on 6/11/24.
//

import Foundation

final class MockAnalyticsService: LogAnalyticsService {
    func logEvent(name: String, label: String, value: String, category: String) {
        debugPrint("\(label) \(category) \(value)")
    }
    
    func logEvent(label: EventLabelType, category: EventParameter.EventCategory, value: Any) {
        debugPrint("\(label) \(category) \(value)")
    }
    
    func logEvent(label: EventLabelType, category: EventParameter.EventCategory, value: Any, previousPage: String?, currentPage: String?, durationTime: String?) {
        debugPrint("\(label) \(category) \(value) \(previousPage ?? "") \(currentPage ?? "") \(durationTime ?? "")")
    }
    
    func logEventWithSessionId(label: EventLabelType, category: EventParameter.EventCategory, value: Any, sessionId: String) {
        debugPrint("\(label) \(category) \(value) \(sessionId)")
    }
}
