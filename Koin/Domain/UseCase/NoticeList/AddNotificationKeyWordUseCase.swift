//
//  AddNotificationKeyWordUseCase.swift
//  koin
//
//  Created by JOOMINKYUNG on 8/24/24.
//

import Combine

protocol AddNotificationKeyWordUseCase {
    func execute(keyword: NoticeKeyWordDTO) -> AnyPublisher<NoticeKeyWordDTO, ErrorResponse>
}

final class DefaultAddNotificationKeyWordUseCase: AddNotificationKeyWordUseCase {
    private let noticeListRepository: NoticeListRepository
    
    init(noticeListRepository: NoticeListRepository) {
        self.noticeListRepository = noticeListRepository
    }
    
    func execute(keyword: NoticeKeyWordDTO) -> AnyPublisher<NoticeKeyWordDTO, ErrorResponse> {
        noticeListRepository.createNotificationKeyWord(requestModel: keyword)
    }
}
