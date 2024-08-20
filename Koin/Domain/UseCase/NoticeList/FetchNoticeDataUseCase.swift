//
//  FetchNoticeDataUseCase.swift
//  koin
//
//  Created by JOOMINKYUNG on 8/19/24.
//

import Combine
import Foundation

protocol FetchNoticeDataUseCase {
    func fetchNoticeData(request: FetchNoticeDataRequest) -> AnyPublisher<NoticeDataInfo, Error>
}

final class DefaultFetchNoticeDataUseCase: FetchNoticeDataUseCase {
    let noticeListRepository: NoticeListRepository
    
    init(noticeListRepository: NoticeListRepository) {
        self.noticeListRepository = noticeListRepository
    }
    
    func fetchNoticeData(request: FetchNoticeDataRequest) -> AnyPublisher<NoticeDataInfo, Error> {
        return noticeListRepository.fetchNoticeData(requestModel: request).map { data in
            data.toDomain()
        }.eraseToAnyPublisher()
    }
}
