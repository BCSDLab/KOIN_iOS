//
//  FetchHotKeywordUseCase.swift
//  koin
//
//  Created by JOOMINKYUNG on 9/1/24.
//

import Combine

protocol FetchRecommendedKeywordUseCase {
    func execute(filters: [NoticeKeywordDTO]) -> AnyPublisher<NoticeRecommendedKeywordDTO, Error>
}

final class DefaultFetchRecommendedKeywordUseCase: FetchRecommendedKeywordUseCase {
    let noticeListRepository: NoticeListRepository
    
    init(noticeListRepository: NoticeListRepository) {
        self.noticeListRepository = noticeListRepository
    }
    
    func execute(filters: [NoticeKeywordDTO]) -> AnyPublisher<NoticeRecommendedKeywordDTO, Error> {
        return noticeListRepository.fetchRecommendedKeyword(count: nil)
            .map { recommendedKeywordDTO in
                let filteredKeywords = recommendedKeywordDTO.keywords.filter { keyword in
                    !filters.contains { $0.keyword == keyword }
                }
                return NoticeRecommendedKeywordDTO(keywords: filteredKeywords)
            }
            .eraseToAnyPublisher()
    }
}

