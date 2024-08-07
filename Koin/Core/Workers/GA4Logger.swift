//
//  GA4Logger.swift
//  koin
//
//  Created by 김나훈 on 6/10/24.
//

import FirebaseAnalytics

final class GA4Logger {
    static let shared = GA4Logger()
    
    private init() { }
    
    func logEvent(label: EventLabelType, category: EventParameter.EventCategory, value: Any) {
        let parameters = [
            "event_label": label.rawValue,
            "event_category": category.rawValue,
            "value": value
        ]
        Analytics.logEvent(label.team, parameters: parameters)
    }
    
}
