//
//  DeleteNotificationKeyWordUseCase.swift
//  koin
//
//  Created by JOOMINKYUNG on 8/27/24.
//

import Combine

protocol DeleteNotificationKeyWordUseCase {
    func deleteNotificationKeyWordWithLogin(id: Int) -> AnyPublisher<Void, ErrorResponse>
    func deleteNotificationKeyWordWithoutLogin(keyWord: NoticeKeyWordDTO)
}

final class DefaultDeleteNotificationKeyWordUseCase: DeleteNotificationKeyWordUseCase {
    private let noticeListRepository: NoticeListRepository
    
    init(noticeListRepository: NoticeListRepository) {
        self.noticeListRepository = noticeListRepository
    }
    
    func deleteNotificationKeyWordWithLogin(id: Int) -> AnyPublisher<Void, ErrorResponse> {
        return noticeListRepository.deleteNotificationKeyWord(requestModel: id).eraseToAnyPublisher()
    }
    
    func deleteNotificationKeyWordWithoutLogin(keyWord: NoticeKeyWordDTO) {
        let keyWord = NoticeKeyWordInfo(context: CoreDataManager.shared.context)
        keyWord.name = keyWord.name
        
        CoreDataManager.shared.delete(deletedObject: keyWord)
    }
    
}
