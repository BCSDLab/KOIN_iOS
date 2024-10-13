//
//  DeleteNotificationKeywordUseCase.swift
//  koin
//
//  Created by JOOMINKYUNG on 8/27/24.
//

import Combine
import Foundation

protocol DeleteNotificationKeywordUseCase {
    func execute(keyword: NoticeKeywordDTO) -> AnyPublisher<Void, ErrorResponse>
}

final class DefaultDeleteNotificationKeywordUseCase: DeleteNotificationKeywordUseCase {
    private let noticeListRepository: NoticeListRepository
    
    init(noticeListRepository: NoticeListRepository) {
        self.noticeListRepository = noticeListRepository
    }
    
    func execute(keyword: NoticeKeywordDTO) -> AnyPublisher<Void, ErrorResponse> {
        noticeListRepository.deleteNotificationKeyword(requestModel: keyword)
    }
}
