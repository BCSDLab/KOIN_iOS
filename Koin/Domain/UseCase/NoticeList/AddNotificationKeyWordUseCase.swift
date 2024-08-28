//
//  AddNotificationKeyWordUseCase.swift
//  koin
//
//  Created by JOOMINKYUNG on 8/24/24.
//

import Combine

protocol AddNotificationKeyWordUseCase {
    func addNotificationKeyWordWithLogin(requestModel: NoticeKeyWordDTO) -> AnyPublisher<NoticeKeyWordDTO, ErrorResponse>
    func addNotificationKeyWordWithoutLogin(requestModel: NoticeKeyWordDTO)
}

final class DefaultAddNotificationKeyWordUseCase: AddNotificationKeyWordUseCase {
    private let noticeListRepository: NoticeListRepository
    
    init(noticeListRepository: NoticeListRepository) {
        self.noticeListRepository = noticeListRepository
    }
    
    func addNotificationKeyWordWithLogin(requestModel: NoticeKeyWordDTO) -> AnyPublisher<NoticeKeyWordDTO, ErrorResponse> {
        return noticeListRepository.createNotificationKeyWord(requestModel: requestModel)
            .eraseToAnyPublisher()
    }
    
    func addNotificationKeyWordWithoutLogin(requestModel: NoticeKeyWordDTO) {
        let keyWord = NoticeKeyWordInfo(context: CoreDataManager.shared.context)
        keyWord.name = requestModel.keyWord
        
        CoreDataManager.shared.insert(insertedObject: keyWord)
    }
}