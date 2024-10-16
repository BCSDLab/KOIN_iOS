//
//  FetchRecentSearchedWordUseCase.swift
//  koin
//
//  Created by JOOMINKYUNG on 9/24/24.
//

import Combine
import Foundation

protocol FetchRecentSearchedWordUseCase {
    func execute(limit: Int?) -> [RecentSearchedWordInfo]
}

final class DefaultFetchRecentSearchedWordUseCase: FetchRecentSearchedWordUseCase {
    let noticeListRepository: NoticeListRepository
    
    init(noticeListRepository: NoticeListRepository) {
        self.noticeListRepository = noticeListRepository
    }
    
    func execute(limit: Int?) -> [RecentSearchedWordInfo] {
        let recentWords = noticeListRepository.fetchRecentSearchedWord()
        if let limit = limit {
            return Array(recentWords.prefix(limit))
        }
        
        return Array(recentWords)
    }
}
