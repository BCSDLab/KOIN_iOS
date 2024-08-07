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
    
    func logEvent(label: EventLabelType, category: EventParameter.EventCategory, value: Any, previousPage: String? = nil, currentPage: String? = nil, durationTime: String? = nil, eventLabelNeededDuration: EventParameter.EventLabelNeededDuration? = nil) {
        service.logEvent(label: label, category: category, value: value, previousPage: previousPage, currentPage: currentPage, durationTime: durationTime, eventLabelNeededDuration: eventLabelNeededDuration)
        
        let mockService = MockAnalyticsService()
        mockService.logEvent(label: label, category: category, value: value, previousPage: previousPage, currentPage: currentPage, durationTime: durationTime, eventLabelNeededDuration: eventLabelNeededDuration)
    }
}
