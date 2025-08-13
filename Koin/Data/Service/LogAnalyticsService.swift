//
//  LogAnalyticsService.swift
//  koin
//
//  Created by 김나훈 on 5/27/24.
//

import FirebaseAnalytics

protocol LogAnalyticsService {
    func logEvent(label: EventLabelType, category: EventParameter.EventCategory, value: Any)
    func logEvent(label: EventLabelType, category: EventParameter.EventCategory, value: Any, previousPage: String?, currentPage: String?, durationTime: String?)
    func logEvent(name: String, label: String, value: String, category: String)
    func logEventWithSessionId(label: EventLabelType, category: EventParameter.EventCategory, value: Any, sessionId: String)
}

final class GA4AnalyticsService: LogAnalyticsService {
    func logEvent(name: String, label: String, value: String, category: String) {
        let parameters = [
            "event_label": label,
            "event_category": category,
            "value": value,
            "gender": UserDataManager.shared.gender,
            "major": UserDataManager.shared.major
        ]
//        var text: String = "CAMPUS"
//        if label == "CAMPUS_modal_1" { text = "AB_TEST" }
//        // TODO: 이거 우선 임시로 이렇게.. 나중에 고치기
        Analytics.logEvent(name, parameters: parameters)
    }
    
    func logEvent(label: EventLabelType, category: EventParameter.EventCategory, value: Any) {
        let parameters = [
            "event_label": label.rawValue,
            "event_category": category.rawValue,
            "value": value,
            "gender": UserDataManager.shared.gender,
            "major": UserDataManager.shared.major
        ]
        Analytics.logEvent(label.team, parameters: parameters)
    }
    
    func logEvent(label: EventLabelType, category: EventParameter.EventCategory, value: Any, previousPage: String? = nil, currentPage: String? = nil, durationTime: String? = nil) {
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
    
    func logEventWithSessionId(label: EventLabelType, category: EventParameter.EventCategory, value: Any, sessionId: String) {
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
}
