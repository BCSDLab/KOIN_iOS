//
//  FetchNotificationKeyWordUseCase.swift
//  koin
//
//  Created by JOOMINKYUNG on 8/28/24.
//

import Combine

protocol FetchNotificationKeyWordUseCase {
    func fetchNotificationKeyWordWithLogin(keyWordForFilter: [NoticeKeyWordDTO]?) -> AnyPublisher<[NoticeKeyWordDTO], ErrorResponse>
    func fetchNotificationKeyWordWithoutLogin() -> [NoticeKeyWordDTO]
}

final class DefaultFetchNotificationKeyWordUseCase: FetchNotificationKeyWordUseCase {
    private let noticeListRepository: NoticeListRepository
    
    init(noticeListRepository: NoticeListRepository) {
        self.noticeListRepository = noticeListRepository
    }
    
    func fetchNotificationKeyWordWithLogin(keyWordForFilter: [NoticeKeyWordDTO]?) ->
    AnyPublisher<[NoticeKeyWordDTO], ErrorResponse> {
        noticeListRepository.fetchNotificationKeyWord().map {
            return $0.keyWords
        }.eraseToAnyPublisher()
        
    }
    
    func fetchNotificationKeyWordWithoutLogin() -> [NoticeKeyWordDTO] {
        let data = CoreDataManager.shared.fetchEntities(objectType: NoticeKeyWordInfo.self)
        var myKeyWords: [NoticeKeyWordDTO] = []
        if let data = data {
            for keyWord in data {
                myKeyWords.append(NoticeKeyWordDTO(id: nil, keyWord: keyWord.name ?? ""))
            }
            return myKeyWords
        }
        else {
            return []
        }
    }
}
