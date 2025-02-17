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
    }
    
    // MARK: - Output
    
    enum Output {
        case showToast(String, Bool)
    }
    
    // MARK: - Properties
    
    private let outputSubject = PassthroughSubject<Output, Never>()
    private var subscriptions: Set<AnyCancellable> = []
    private let defaultReportLostItemUseCase: DefaultReportLostItemUseCase = DefaultReportLostItemUseCase(noticeListRepository: DefaultNoticeListRepository(service: DefaultNoticeService()))
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
            }
        }.store(in: &subscriptions)
        return outputSubject.eraseToAnyPublisher()
    }
    
}

extension ReportLostItemViewModel {
    private func reportLostItemArticle(request: ReportLostItemRequest) {
        print(request)
        print(lostItemId)
        defaultReportLostItemUseCase.execute(id: lostItemId, request: request).sink { [weak self] completion in
            if case let .failure(error) = completion {
                self?.outputSubject.send(.showToast(error.message, false))
            }
        } receiveValue: { [weak self] response in
            self?.outputSubject.send(.showToast("게시글이 신고되었습니다.", true))
        }.store(in: &subscriptions)
    
    }
    
}
