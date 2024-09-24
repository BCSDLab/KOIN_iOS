//
//  DeleteNotificationKeyWordUseCase.swift
//  koin
//
//  Created by JOOMINKYUNG on 8/27/24.
//

import Combine
import Foundation

protocol DeleteNotificationKeyWordUseCase {
    func execute(keyword: NoticeKeyWordDTO) -> AnyPublisher<Void, ErrorResponse>
}

final class DefaultDeleteNotificationKeyWordUseCase: DeleteNotificationKeyWordUseCase {
    private let noticeListRepository: NoticeListRepository
    
    init(noticeListRepository: NoticeListRepository) {
        self.noticeListRepository = noticeListRepository
    }
    
    func execute(keyword: NoticeKeyWordDTO) -> AnyPublisher<Void, ErrorResponse> {
        noticeListRepository.deleteNotificationKeyWord(requestModel: keyword)
    }
}
