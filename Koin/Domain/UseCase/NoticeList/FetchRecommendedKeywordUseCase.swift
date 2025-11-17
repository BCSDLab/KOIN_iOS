//
//  FetchHotKeywordUseCase.swift
//  koin
//
//  Created by JOOMINKYUNG on 9/1/24.
//

import Combine

protocol FetchRecommendedKeywordUseCase {
    func execute(filters: [NoticeKeywordDto]) -> AnyPublisher<NoticeRecommendedKeywordDto, Error>
}

final class DefaultFetchRecommendedKeywordUseCase: FetchRecommendedKeywordUseCase {
    let noticeListRepository: NoticeListRepository
    
    init(noticeListRepository: NoticeListRepository) {
        self.noticeListRepository = noticeListRepository
    }
    
    func execute(filters: [NoticeKeywordDto]) -> AnyPublisher<NoticeRecommendedKeywordDto, Error> {
        return noticeListRepository.fetchRecommendedKeyword(count: nil)
            .map { recommendedKeywordDto in
                let filteredKeywords = recommendedKeywordDto.keywords.filter { keyword in
                    !filters.contains { $0.keyword == keyword }
                }
                return NoticeRecommendedKeywordDto(keywords: filteredKeywords)
            }
            .eraseToAnyPublisher()
    }
}

