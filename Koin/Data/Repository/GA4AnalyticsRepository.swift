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
    func logEvent(name: String, label: String, value: String, category: String) {
        return service.logEvent(name: name, label: label, value: value, category: category)
    }
    
    func logEvent(label: EventLabelType, category: EventParameter.EventCategory, value: Any) {
        
        return service.logEvent(label: label, category: category, value: value)
    }
    
    func logEvent(label: EventLabelType, category: EventParameter.EventCategory, value: Any, previousPage: String?, currentPage: String?, durationTime: String?) {
        
        return service.logEvent(label: label, category: category, value: value, previousPage: previousPage, currentPage: currentPage, durationTime: durationTime)
    }
}
