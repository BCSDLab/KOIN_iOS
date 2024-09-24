//
//  FetchNotificationKeyWordUseCase.swift
//  koin
//
//  Created by JOOMINKYUNG on 8/28/24.
//

import Combine

protocol FetchNotificationKeyWordUseCase {
    func execute() -> AnyPublisher<([NoticeKeyWordDTO], Bool), ErrorResponse>
}

final class DefaultFetchNotificationKeyWordUseCase: FetchNotificationKeyWordUseCase {
    private let noticeListRepository: NoticeListRepository
    
    init(noticeListRepository: NoticeListRepository) {
        self.noticeListRepository = noticeListRepository
    }
    
    func execute() -> AnyPublisher<([NoticeKeyWordDTO], Bool), ErrorResponse> {
        noticeListRepository.fetchNotificationKeyWord().map { fetchResult in
            switch fetchResult {
            case let .success(keywords):
                return (keywords.keyWords, true)
            case let .successWithCoreData(keywords):
                return (keywords.keyWords, false)
            }
        }.eraseToAnyPublisher()
    }
}
