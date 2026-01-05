//
//  ShopReviewReportViewModel.swift
//  koin
//
//  Created by 김나훈 on 8/12/24.
//

import Combine

final class ShopReviewReportViewModel: ViewModelProtocol {
    
    // MARK: - Input
    
    enum Input {
        case reportReview(ReportReviewRequest,[String])
    }
    
    // MARK: - Output
    
    enum Output {
        case showToast(String)
        case sendReviewInfo(Int, Int)
    }
    
    // MARK: - Properties
    
    private let outputSubject = PassthroughSubject<Output, Never>()
    private var subscriptions: Set<AnyCancellable> = []
    private let reportReviewReviewUseCase: ReportReviewReviewUseCase
    private let logAnalyticsEventUseCase: LogAnalyticsEventUseCase
    private let reviewId: Int
    private let shopId: Int
    private let shopName: String
    private let completion: (Int, Int)->Void
    
    // MARK: - Initialization
    
    init(reportReviewReviewUseCase: ReportReviewReviewUseCase, logAnalyticsEventUseCase: LogAnalyticsEventUseCase, reviewId: Int, shopId: Int, shopName: String, completion: @escaping (Int, Int)->Void) {
        self.reportReviewReviewUseCase = reportReviewReviewUseCase
        self.logAnalyticsEventUseCase = logAnalyticsEventUseCase
        self.reviewId = reviewId
        self.shopId = shopId
        self.shopName = shopName
        self.completion = completion
    }
    
    func transform(with input: AnyPublisher<Input, Never>) -> AnyPublisher<Output, Never> {
        input.sink { [weak self] input in
            switch input {
            case let .reportReview(requestModel,selectedItems):
                self?.reportReview(requestModel,selectedItems)
            }
        }.store(in: &subscriptions)
        return outputSubject.eraseToAnyPublisher()
    }
    
}

extension ShopReviewReportViewModel {
   
    private func reportReview(_ requestModel: ReportReviewRequest, _ selectedItems: [String]) {
        reportReviewReviewUseCase.execute(requestModel: requestModel, reviewId: reviewId, shopId: shopId).sink { [weak self] completion in
            if case let .failure(error) = completion {
                self?.outputSubject.send(.showToast(error.message))
            }
        } receiveValue: { [weak self] _ in
            guard let self = self else { return }
            self.outputSubject.send(.sendReviewInfo(self.reviewId, self.shopId))
            let value = selectedItems.joined(separator: ",")
            self.completion(self.reviewId, self.shopId)
            self.makeLogAnalyticsEvent(label: EventParameter.EventLabel.Business.shopDetailViewReviewReport, category: .click, value: value)
        }.store(in: &subscriptions)
    }
    
    private func makeLogAnalyticsEvent(label: EventLabelType, category: EventParameter.EventCategory, value: Any) {
        logAnalyticsEventUseCase.execute(label: label, category: category, value: value)
    }
}
