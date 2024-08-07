//
//  LogAnalyticsEventUseCase.swift
//  koin
//
//  Created by 김나훈 on 5/27/24.
//

import Foundation

protocol LogAnalyticsEventUseCase {
    func execute(label: EventLabelType, category: EventParameter.EventCategory, value: Any)
}

final class DefaultLogAnalyticsEventUseCase: LogAnalyticsEventUseCase {
    
    private let repository: AnalyticsRepository
    
    init(repository: AnalyticsRepository) {
        self.repository = repository
    }
    func execute(label: EventLabelType, category: EventParameter.EventCategory, value: Any) {
        repository.logEvent(label: label, category: category , value: value)
    }

}
