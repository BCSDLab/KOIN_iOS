//
//  LogAnalyticsEventUseCase.swift
//  koin
//
//  Created by 김나훈 on 5/27/24.
//

import Foundation

protocol LogAnalyticsEventUseCase {
    func execute(label: EventLabelType, category: EventParameter.EventCategory, value: Any)
    func executeWithDuration(label: EventLabelType, category: EventParameter.EventCategory, value: Any, previousPage: String?, currentPage: String?, durationTime: String?)
}

final class DefaultLogAnalyticsEventUseCase: LogAnalyticsEventUseCase {
    
    private let repository: AnalyticsRepository
    
    init(repository: AnalyticsRepository) {
        self.repository = repository
    }
    func execute(label: EventLabelType, category: EventParameter.EventCategory, value: Any) {
        repository.logEvent(label: label, category: category, value: value)
    }
    func executeWithDuration(label: EventLabelType, category: EventParameter.EventCategory, value: Any, previousPage: String? = nil, currentPage: String? = nil, durationTime: String? = nil) {
        repository.logEvent(label: label, category: category, value: value, previousPage: previousPage, currentPage: currentPage, durationTime: durationTime)
    }
}
