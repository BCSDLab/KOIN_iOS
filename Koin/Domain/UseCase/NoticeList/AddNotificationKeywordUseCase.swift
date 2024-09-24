//
//  AddNotificationKeywordUseCase.swift
//  koin
//
//  Created by JOOMINKYUNG on 8/24/24.
//

import Combine

protocol AddNotificationKeywordUseCase {
    func execute(keyword: NoticeKeywordDTO) -> AnyPublisher<NoticeKeywordDTO, ErrorResponse>
}

final class DefaultAddNotificationKeywordUseCase: AddNotificationKeywordUseCase {
    private let noticeListRepository: NoticeListRepository
    
    init(noticeListRepository: NoticeListRepository) {
        self.noticeListRepository = noticeListRepository
    }
    
    func execute(keyword: NoticeKeywordDTO) -> AnyPublisher<NoticeKeywordDTO, ErrorResponse> {
        noticeListRepository.createNotificationKeyword(requestModel: keyword)
    }
}
