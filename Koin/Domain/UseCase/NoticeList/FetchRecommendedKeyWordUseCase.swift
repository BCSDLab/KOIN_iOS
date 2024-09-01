//
//  FetchRecommendedKeyWordUseCase.swift
//  koin
//
//  Created by JOOMINKYUNG on 8/28/24.
//

import Combine

protocol FetchRecommendedKeyWordUseCase {
    func execute() -> AnyPublisher<[NoticeKeyWordDTO], ErrorResponse>
}

final class DefaultFetchRecommendedKeyWordUseCase: FetchRecommendedKeyWordUseCase {
    private let noticeListRepository: NoticeListRepository
    
    init(noticeListRepository: NoticeListRepository) {
        self.noticeListRepository = noticeListRepository
    }
    
    func execute() -> AnyPublisher<[NoticeKeyWordDTO], ErrorResponse> {
        noticeListRepository.fetchNotificationKeyWord(isMyKeyWord: false).map {
            return $0.keyWords
        }.eraseToAnyPublisher()
    }
}
