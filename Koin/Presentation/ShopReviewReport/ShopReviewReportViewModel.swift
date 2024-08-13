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
        case reportReview(ReportReviewRequest)
    }
    
    // MARK: - Output
    
    enum Output {
        case showToast(String, Bool)
    }
    
    // MARK: - Properties
    
    private let outputSubject = PassthroughSubject<Output, Never>()
    private var subscriptions: Set<AnyCancellable> = []
    private let reportReviewReviewUseCase: ReportReviewReviewUseCase
    private let reviewId: Int
    private let shopId: Int
    
    // MARK: - Initialization
    
    init(reportReviewReviewUseCase: ReportReviewReviewUseCase, reviewId: Int, shopId: Int) {
        self.reportReviewReviewUseCase = reportReviewReviewUseCase
        self.reviewId = reviewId
        self.shopId = shopId
    }
    
    func transform(with input: AnyPublisher<Input, Never>) -> AnyPublisher<Output, Never> {
        input.sink { [weak self] input in
            switch input {
            case let .reportReview(requestModel):
                self?.reportReview(requestModel)
            }
        }.store(in: &subscriptions)
        return outputSubject.eraseToAnyPublisher()
    }
    
}

extension ShopReviewReportViewModel {
   
    private func reportReview(_ requestModel: ReportReviewRequest) {
        reportReviewReviewUseCase.execute(requestModel: requestModel, reviewId: reviewId, shopId: shopId).sink { completion in
            if case let .failure(error) = completion {
                Log.make().error("\(error)")
            }
        } receiveValue: { [weak self] _ in
            self?.outputSubject.send(.showToast("리뷰가 신고되었습니다.", true))
        }.store(in: &subscriptions)

    }

}
