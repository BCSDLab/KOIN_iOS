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
        let service = MockAnalyticsService()
        return service.logEvent(label: label, category: category, value: value)
    }
    
    func logEvent(label: EventLabelType, category: EventParameter.EventCategory, value: Any, previousPage: String?, currentPage: String?, durationTime: String?) {
        let service = MockAnalyticsService()
        return service.logEvent(label: label, category: category, value: value, previousPage: previousPage, currentPage: currentPage, durationTime: durationTime)
    }
}
