//
//  AddNotificationKeyWordUseCase.swift
//  koin
//
//  Created by JOOMINKYUNG on 8/24/24.
//

import Combine

protocol AddNotificationKeyWordUseCase {
    func createNotificationKeyWord(requestModel: NoticeDataViewModel) -> AnyPublisher<[NoticeKeyWordDTO], ErrorResponse>
    func addNotificationKeyWord(requestModel: NoticeKeyWordDTO) -> [NoticeKeyWordDTO]
    func fetchKeyWordEntities() -> [NoticeKeyWordDTO]
}

final class DefaultAddNotificationKeyWordUseCase: AddNotificationKeyWordUseCase {
    private let noticeListRepository: NoticeListRepository
    
    init(noticeListRepository: NoticeListRepository) {
        self.noticeListRepository = noticeListRepository
    }
    
    func createNotificationKeyWord() -> AnyPublisher<[NoticeKeyWordDTO], ErrorResponse> {
        let myKeyWords = fetchKeyWordEntities()
        let publishers: [AnyPublisher<NoticeKeyWordDTO, ErrorResponse>] = myKeyWords.map { keyWord in
                noticeListRepository.createNotificationKeyWord(requestModel: keyWord)
                    .eraseToAnyPublisher()
            }
        return Publishers.MergeMany(publishers)
            .collect()
            .eraseToAnyPublisher()
    }
    
    func addNotificationKeyWord(requestModel: NoticeKeyWordDTO) -> [NoticeKeyWordDTO] {
        let keyWord = NoticeKeyWordInfo(context: CoreDataManager.shared.context)
        keyWord.name = requestModel.keyWord
        
        CoreDataManager.shared.insert(insertedObject: keyWord)
        return fetchKeyWordEntities()
    }
    
    func fetchKeyWordEntities() -> [NoticeKeyWordDTO] {
        var myKeyWords: [NoticeKeyWordDTO] = []
        if let keyWords = CoreDataManager.shared.fetchEntities(objectType: NoticeKeyWordInfo.self) {
            for keyWord in keyWords {
                myKeyWords.append(NoticeKeyWordDTO(id: nil, keyWord: keyWord.name ?? ""))
            }
        }
        return myKeyWords
    }
}
