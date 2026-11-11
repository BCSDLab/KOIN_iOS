//
//  AnalyticsRepository.swift
//  koin
//
//  Created by 김나훈 on 5/27/24.
//

import Foundation

protocol AnalyticsRepository {
    func logEvent(label: EventLabelType, value: Any, category: EventParameter.EventCategory?, parameters: [String: String])
}
