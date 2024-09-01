//
//  FetchNotificationKeyWordUseCase.swift
//  koin
//
//  Created by JOOMINKYUNG on 8/28/24.
//

import Combine

protocol FetchNotificationKeyWordUseCase {
    func fetchNotificationKeyWordUseCaseWithLogin() -> AnyPublisher<[NoticeKeyWordDTO], ErrorResponse>
    func fetchNotificationKeyWordUseCaseWithoutLogin() -> [NoticeKeyWordDTO]
}

final class DefaultFetchNotificationKeyWordUseCase: FetchNotificationKeyWordUseCase {
    private let noticeListRepository: NoticeListRepository
    
    init(noticeListRepository: NoticeListRepository) {
        self.noticeListRepository = noticeListRepository
    }
    
    func fetchNotificationKeyWordUseCaseWithLogin() -> AnyPublisher<[NoticeKeyWordDTO], ErrorResponse> {
        noticeListRepository.fetchNotificationKeyWord(isMyKeyWord: true).map {
            return $0.keyWords
        }.eraseToAnyPublisher()
    }
    
    func fetchNotificationKeyWordUseCaseWithoutLogin() -> [NoticeKeyWordDTO] {
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
    
    private func makeTestData() -> AnyPublisher<[NoticeKeyWordDTO], ErrorResponse> {
        let data = [
                NoticeKeyWordDTO(id: 1, keyWord: "교환학생"),
                NoticeKeyWordDTO(id: 2, keyWord: "장학금"),
                NoticeKeyWordDTO(id: 3, keyWord: "학사"),
                NoticeKeyWordDTO(id: 4, keyWord: "근장"),
                NoticeKeyWordDTO(id: 5, keyWord: "졸업"),
                NoticeKeyWordDTO(id: 6, keyWord: "설명회"),
                NoticeKeyWordDTO(id: 7, keyWord: "인공지능"),
                NoticeKeyWordDTO(id: 8, keyWord: "방학")
            ]
        return Just(data)
            .setFailureType(to: ErrorResponse.self)
            .eraseToAnyPublisher()
    }
}
