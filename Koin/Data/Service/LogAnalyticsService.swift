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
}

final class GA4AnalyticsService: LogAnalyticsService {
    func logEvent(label: EventLabelType, category: EventParameter.EventCategory, value: Any) {
        let parameters: [String: Any] = [
            "event_label": label.rawValue,
            "event_category": category.rawValue,
            "value": value,
            "user_id": UserDataManager.shared.userId,
            "gender": UserDataManager.shared.gender,
            "major": UserDataManager.shared.major
        ]
        
        // 🔥 Firebase 로그 저장 + 토스트 출력
        Analytics.logEvent(label.team, parameters: parameters)
        ToastManager.shared.showToast(parameters: parameters)
    }
    
    func logEvent(label: EventLabelType, category: EventParameter.EventCategory, value: Any, previousPage: String? = nil, currentPage: String? = nil, durationTime: String? = nil) {
        var parameters: [String: Any] = [
            "event_label": label.rawValue,
            "event_category": category.rawValue,
            "value": value,
            "user_id": UserDataManager.shared.userId,
            "gender": UserDataManager.shared.gender,
            "major": UserDataManager.shared.major
        ]
        
        if let previousPage = previousPage {
            parameters["previous_page"] = previousPage
        }
        if let currentPage = currentPage {
            parameters["current_page"] = currentPage
        }
        if let durationTime = durationTime {
            parameters["duration_time"] = durationTime
        }
        
        // 🔥 Firebase 로그 저장 + 토스트 출력
        Analytics.logEvent(label.team, parameters: parameters)
        ToastManager.shared.showToast(parameters: parameters)
    }
}
