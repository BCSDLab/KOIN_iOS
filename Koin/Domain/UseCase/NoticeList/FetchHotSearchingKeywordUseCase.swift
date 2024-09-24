//
//  FetchHotSearchingKeywordUseCase.swift
//  koin
//
//  Created by JOOMINKYUNG on 9/2/24.
//

import Combine

protocol FetchHotSearchingKeywordUseCase {
    func execute(count: Int) -> AnyPublisher<[String], Error>
}

final class DefaultFetchHotSearchingKeywordUseCase: FetchHotSearchingKeywordUseCase {
    let noticeListRepository: NoticeListRepository
    
    init(noticeListRepository: NoticeListRepository) {
        self.noticeListRepository = noticeListRepository
    }
    
    func execute(count: Int) -> AnyPublisher<[String], Error> {
        return noticeListRepository.fetchRecommendedKeyword(count: count).map { keywords in
            return keywords.keywords.map { keyword in
                "#\(keyword)"
            }
        }.eraseToAnyPublisher()
    }
}
