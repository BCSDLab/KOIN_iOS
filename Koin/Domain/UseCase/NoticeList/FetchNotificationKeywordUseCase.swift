//
//  FetchNotificationKeywordUseCase.swift
//  koin
//
//  Created by JOOMINKYUNG on 8/28/24.
//

import Combine

protocol FetchNotificationKeywordUseCase {
    func execute() -> AnyPublisher<([NoticeKeywordDTO], Bool), ErrorResponse>
}

final class DefaultFetchNotificationKeywordUseCase: FetchNotificationKeywordUseCase {
    private let noticeListRepository: NoticeListRepository
    
    init(noticeListRepository: NoticeListRepository) {
        self.noticeListRepository = noticeListRepository
    }
    
    func execute() -> AnyPublisher<([NoticeKeywordDTO], Bool), ErrorResponse> {
        noticeListRepository.fetchNotificationKeyword().map { fetchResult in
            switch fetchResult {
            case let .success(keywords):
                return (keywords.keywords, true)
            case let .successWithCoreData(keywords):
                return (keywords.keywords, false)
            }
        }.eraseToAnyPublisher()
    }
}
