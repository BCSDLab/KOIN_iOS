//
//  FetchHotKeyWordUseCase.swift
//  koin
//
//  Created by JOOMINKYUNG on 9/1/24.
//

import Combine

protocol FetchRecommendedKeyWordUseCase {
    func execute(filters: [NoticeKeyWordDTO]) -> AnyPublisher<NoticeRecommendedKeyWordDTO, Error>
}

final class DefaultFetchRecommendedKeyWordUseCase: FetchRecommendedKeyWordUseCase {
    let noticeListRepository: NoticeListRepository
    
    init(noticeListRepository: NoticeListRepository) {
        self.noticeListRepository = noticeListRepository
    }
    
    func execute(filters: [NoticeKeyWordDTO]) -> AnyPublisher<NoticeRecommendedKeyWordDTO, Error> {
        return noticeListRepository.fetchRecommendedKeyWord(count: nil)
            .map { recommendedKeyWordDTO in
                let filteredKeywords = recommendedKeyWordDTO.keywords.filter { keyword in
                    !filters.contains { $0.keyWord == keyword }
                }
                return NoticeRecommendedKeyWordDTO(keywords: filteredKeywords)
            }
            .eraseToAnyPublisher()
    }
}

