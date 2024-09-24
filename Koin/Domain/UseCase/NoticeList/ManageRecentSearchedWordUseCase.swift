//
//  ManageRecentSearchedWordUseCase.swift
//  koin
//
//  Created by JOOMINKYUNG on 9/2/24.
//

import Combine
import Foundation

protocol ManageRecentSearchedWordUseCase {
    func execute(name: String, date: Date, actionType: Int)
}

final class DefaultManageRecentSearchedWordUseCase: ManageRecentSearchedWordUseCase {
    let noticeListRepository: NoticeListRepository
    
    init(noticeListRepository: NoticeListRepository) {
        self.noticeListRepository = noticeListRepository
    }
    
    func execute(name: String, date: Date, actionType: Int) {
        noticeListRepository.manageRecentSearchedWord(name: name, date: date, actionType: actionType)
    }
}
