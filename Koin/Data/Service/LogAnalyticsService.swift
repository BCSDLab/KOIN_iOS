//
//  LogAnalyticsService.swift
//  koin
//
//  Created by 김나훈 on 5/27/24.
//

import FirebaseAnalytics

protocol LogAnalyticsService {
    func logEvent(label: EventLabelType, category: EventParameter.EventCategory, value: Any, previousPage: String?, currentPage: String?, durationTime: String?, eventLabelNeededDuration: EventParameter.EventLabelNeededDuration?)
}

final class GA4AnalyticsService: LogAnalyticsService {
    func logEvent(label: EventLabelType, category: EventParameter.EventCategory, value: Any, previousPage: String? = nil, currentPage: String? = nil, durationTime: String? = nil, eventLabelNeededDuration: EventParameter.EventLabelNeededDuration? = nil) {
        if eventLabelNeededDuration == nil {
            let parameters = [
                "event_label": label.rawValue,
                "event_category": category.rawValue,
                "value": value
            ]
            Analytics.logEvent(label.team, parameters: parameters)
        }
        else if eventLabelNeededDuration == .shopCall {
            if let durationTime = durationTime {
                let parameters = [
                    "event_label": label.rawValue,
                    "event_category": category.rawValue,
                    "value": value,
                    "duration_time": durationTime
                ]
                Analytics.logEvent(label.team, parameters: parameters)
            }
        }
        else if eventLabelNeededDuration == .shopDetailViewBack {
            if let durationTime = durationTime,
               let currentPage = currentPage {
                let parameters = [
                    "event_label": label.rawValue,
                    "event_category": category.rawValue,
                    "value": value,
                    "currentPage": currentPage,
                    "duration_time": durationTime
                ]
                Analytics.logEvent(label.team, parameters: parameters)
            }
        }
        else {
            if let previousPage = previousPage,
               let currentPage = currentPage,
               let durationTime = durationTime {
                let parameters = [
                    "event_label": label.rawValue,
                    "event_category": category.rawValue,
                    "value": value,
                    "previous_page": previousPage,
                    "current_page": currentPage,
                    "duration_time": durationTime
                ]
                Analytics.logEvent(label.team, parameters: parameters)
            }
        }
    }
}
