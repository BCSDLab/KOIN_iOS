//
//  LogAnalyticsEventUseCase.swift
//  koin
//
//  Created by 김나훈 on 5/27/24.
//

import Foundation

protocol LogAnalyticsEventUseCase {
    func execute(label: EventLabelType, value: Any, category: EventParameter.EventCategory?, parameters: [String: String])
}

extension LogAnalyticsEventUseCase {
    /// category는 명세의 category가 label 마지막 구간과 다를 때만 넘긴다.
    func execute(label: EventLabelType, value: Any, category: EventParameter.EventCategory? = nil) {
        execute(label: label, value: value, category: category, parameters: [:])
    }

    func execute(label: EventLabelType, value: Any, parameters: [String: String]) {
        execute(label: label, value: value, category: nil, parameters: parameters)
    }
}

final class DefaultLogAnalyticsEventUseCase: LogAnalyticsEventUseCase {
    
    private let repository: AnalyticsRepository
    
    init(repository: AnalyticsRepository) {
        self.repository = repository
    }
    
    func execute(label: EventLabelType, value: Any, category: EventParameter.EventCategory?, parameters: [String: String]) {
        repository.logEvent(label: label, value: value, category: category, parameters: parameters)
    }
}
