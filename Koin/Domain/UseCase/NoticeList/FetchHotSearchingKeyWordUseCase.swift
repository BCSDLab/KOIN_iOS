//
//  FetchHotSearchingKeyWordUseCase.swift
//  koin
//
//  Created by JOOMINKYUNG on 9/2/24.
//

import Combine

protocol FetchHotSearchingKeyWordUseCase {
    func execute(count: Int) -> AnyPublisher<[String], Error>
}

final class DefaultFetchHotSearchingKeyWordUseCase: FetchHotSearchingKeyWordUseCase {
    let noticeListRepository: NoticeListRepository
    
    init(noticeListRepository: NoticeListRepository) {
        self.noticeListRepository = noticeListRepository
    }
    
    func execute(count: Int) -> AnyPublisher<[String], Error> {
        return noticeListRepository.fetchRecommendedKeyWord(count: count).map { keyWords in
            return keyWords.keywords.map { keyWord in
                "#\(keyWord)"
            }
        }.eraseToAnyPublisher()
    }
}
