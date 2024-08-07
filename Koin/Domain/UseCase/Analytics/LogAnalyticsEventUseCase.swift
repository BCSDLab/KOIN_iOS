//
//  LogAnalyticsEventUseCase.swift
//  koin
//
//  Created by 김나훈 on 5/27/24.
//

import Foundation

protocol LogAnalyticsEventUseCase {
    func execute(label: EventLabelType, category: EventParameter.EventCategory, value: Any)
    func executeWithDuration(label: EventLabelType, category: EventParameter.EventCategory, value: Any, previousPage: String?, currentPage: String?, durationTime: String?, eventLabelNeededDuration: EventParameter.EventLabelNeededDuration?)
}

final class DefaultLogAnalyticsEventUseCase: LogAnalyticsEventUseCase {
    
    private let repository: AnalyticsRepository
    
    init(repository: AnalyticsRepository) {
        self.repository = repository
    }
    func execute(label: EventLabelType, category: EventParameter.EventCategory, value: Any) {
        repository.logEvent(label: label, category: category, value: value, previousPage: nil, currentPage: nil, durationTime: nil, eventLabelNeededDuration: nil)
    }
    func executeWithDuration(label: EventLabelType, category: EventParameter.EventCategory, value: Any, previousPage: String? = nil, currentPage: String? = nil, durationTime: String? = nil, eventLabelNeededDuration: EventParameter.EventLabelNeededDuration? = nil) {
        repository.logEvent(label: label, category: category, value: value, previousPage: previousPage, currentPage: currentPage, durationTime: durationTime, eventLabelNeededDuration: eventLabelNeededDuration)
    }
}
