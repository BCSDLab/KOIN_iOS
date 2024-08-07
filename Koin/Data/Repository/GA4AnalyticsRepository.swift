//
//  GA4AnalyticsRepository.swift
//  koin
//
//  Created by 김나훈 on 5/27/24.
//


final class GA4AnalyticsRepository: AnalyticsRepository {
    
    private let service: LogAnalyticsService
    
    init(service: LogAnalyticsService) {
        self.service = service
    }
    
    func logEvent(label: EventLabelType, category: EventParameter.EventCategory, value: Any) {
        service.logEvent(label: label, category: category, value: value)
    }
    
}
