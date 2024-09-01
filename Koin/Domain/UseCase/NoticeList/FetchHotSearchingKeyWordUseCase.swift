//
//  FetchHotSearchingKeyWordUseCase.swift
//  koin
//
//  Created by JOOMINKYUNG on 9/2/24.
//

import Combine

protocol FetchHotSearchingKeyWordUseCase {
    func execute(count: Int) -> AnyPublisher<NoticeRecommendedKeyWordDTO, Error>
}

final class DefaultFetchHotSearchingKeyWordUseCase: FetchHotSearchingKeyWordUseCase {
    let noticeListRepository: NoticeListRepository
    
    init(noticeListRepository: NoticeListRepository) {
        self.noticeListRepository = noticeListRepository
    }
    
    func execute(count: Int) -> AnyPublisher<NoticeRecommendedKeyWordDTO, Error> {
        return noticeListRepository.fetchRecommendedKeyWord(count: count).eraseToAnyPublisher()
    }
}
