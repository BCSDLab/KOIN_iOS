//
//  AnalyticsRepository.swift
//  koin
//
//  Created by 김나훈 on 5/27/24.
//

import Foundation

protocol AnalyticsRepository {
    func logEvent(label: EventLabelType, category: EventParameter.EventCategory, value: Any)
    func logEvent(label: EventLabelType, category: EventParameter.EventCategory, value: Any, previousPage: String?, currentPage: String?, durationTime: String?)
    func logEvent(name: String, label: String, value: String, category: String)
    func logEventWithSessionId(label: EventLabelType, category: EventParameter.EventCategory, value: Any, sessionId: String)
}
