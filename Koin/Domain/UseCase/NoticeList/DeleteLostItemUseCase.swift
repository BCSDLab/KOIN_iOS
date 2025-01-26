//
//  DeleteLostItemUseCase.swift
//  koin
//
//  Created by 김나훈 on 1/15/25.
//

import Combine

protocol DeleteLostItemUseCase {
    func execute(id: Int) -> AnyPublisher<Void, ErrorResponse>
}

final class DefaultDeleteLostItemUseCase: DeleteLostItemUseCase {
    
    private let noticeListRepository: NoticeListRepository
    
    init(noticeListRepository: NoticeListRepository) {
        self.noticeListRepository = noticeListRepository
    }
    
    func execute(id: Int) -> AnyPublisher<Void, ErrorResponse> {
        noticeListRepository.deleteLostItem(id: id)
    }
}
