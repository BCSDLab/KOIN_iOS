//
//  ReportLostItemRequest.swift
//  koin
//
//  Created by 김나훈 on 2/17/25.
//

import Combine

protocol ReportLostItemUseCase {
    func execute(id: Int, request: ReportLostItemRequest) -> AnyPublisher<Void, ErrorResponse>
}

final class DefaultReportLostItemUseCase: ReportLostItemUseCase {
    
    private let lostItemRepository: LostItemRepository
    
    init(lostItemRepository: LostItemRepository) {
        self.lostItemRepository = lostItemRepository
    }
    
    func execute(id: Int, request: ReportLostItemRequest) -> AnyPublisher<Void, ErrorResponse> {
        lostItemRepository.reportLostItemArticle(id: id, request: request)
    }
}


