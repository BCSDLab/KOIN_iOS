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
    
    private let noticeListRepository: NoticeListRepository
    
    init(noticeListRepository: NoticeListRepository) {
        self.noticeListRepository = noticeListRepository
    }
    
    func execute(id: Int, request: ReportLostItemRequest) -> AnyPublisher<Void, ErrorResponse> {
        noticeListRepository.reportLostItemArticle(id: id, request: request)
    }
}


