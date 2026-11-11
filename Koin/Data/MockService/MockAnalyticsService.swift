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
}
