//
//  ReportLostItemViewModel.swift
//  koin
//
//  Created by 김나훈 on 2/16/25.
//

import Combine
import Foundation

final class ReportLostItemViewModel: ViewModelProtocol {
    
    // MARK: - Input
    
    enum Input {
        case reportLostItemArticle(ReportLostItemRequest)
        case logEvent(EventLabelType, EventParameter.EventCategory, Any)
    }
    
    // MARK: - Output
    
    enum Output {
        case showToast(String, Bool)
    }
    
    // MARK: - Properties
    
    private let outputSubject = PassthroughSubject<Output, Never>()
    private var subscriptions: Set<AnyCancellable> = []
    private let defaultReportLostItemUseCase: DefaultReportLostItemUseCase = DefaultReportLostItemUseCase(noticeListRepository: DefaultNoticeListRepository(service: DefaultNoticeService()))
    private let logAnalyticsEventUseCase: LogAnalyticsEventUseCase = DefaultLogAnalyticsEventUseCase(repository: GA4AnalyticsRepository(service: GA4AnalyticsService()))
    private let lostItemId: Int
    
    
    // MARK: - Initialization
    
    init(noticeId: Int) {
        self.lostItemId = noticeId
    }
    
    func transform(with input: AnyPublisher<Input, Never>) -> AnyPublisher<Output, Never> {
        input.sink { [weak self] input in
            switch input {
            case .reportLostItemArticle(let request):
                self?.reportLostItemArticle(request: request)
            case let .logEvent(label, category, value):
                self?.makeLogAnalyticsEvent(label: label, category: category, value: value)
            }
        }.store(in: &subscriptions)
        return outputSubject.eraseToAnyPublisher()
    }
    
}

extension ReportLostItemViewModel {
    private func reportLostItemArticle(request: ReportLostItemRequest) {
        defaultReportLostItemUseCase.execute(id: lostItemId, request: request).sink { [weak self] completion in
            if case let .failure(error) = completion {
                self?.outputSubject.send(.showToast(error.message, false))
            }
        } receiveValue: { [weak self] response in
            fetch = true
            self?.outputSubject.send(.showToast("게시글이 신고되었습니다.", true))
        }.store(in: &subscriptions)
    
    }
    private func makeLogAnalyticsEvent(label: EventLabelType, category: EventParameter.EventCategory, value: Any) {
        logAnalyticsEventUseCase.execute(label: label, category: category, value: value)
    }
}
