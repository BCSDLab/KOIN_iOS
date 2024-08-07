//
//  MockAnalyticesService.swift
//  koin
//
//  Created by 김나훈 on 6/11/24.
//

import Foundation

final class MockAnalyticsService: LogAnalyticsService {
    func logEvent(label: EventLabelType, category: EventParameter.EventCategory, value: Any, previousPage: String?, currentPage: String?, durationTime: String?, eventLabelNeededDuration: EventParameter.EventLabelNeededDuration?) {
        debugPrint("\(label) \(category) \(value) \(previousPage ?? "") \(currentPage ?? "") \(durationTime ?? "")")
    }
}
