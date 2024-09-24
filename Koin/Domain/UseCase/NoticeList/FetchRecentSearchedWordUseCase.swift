//
//  FetchRecentSearchedWordUseCase.swift
//  koin
//
//  Created by JOOMINKYUNG on 9/24/24.
//

import Combine
import Foundation

protocol FetchRecentSearchedWordUseCase {
    func execute() -> [RecentSearchedWordInfo]
}

final class DefaultFetchRecentSearchedWordUseCase: FetchRecentSearchedWordUseCase {
    let noticeListRepository: NoticeListRepository
    
    init(noticeListRepository: NoticeListRepository) {
        self.noticeListRepository = noticeListRepository
    }
    
    func execute() -> [RecentSearchedWordInfo] {
        return noticeListRepository.fetchRecentSearchedWord()
    }
}
