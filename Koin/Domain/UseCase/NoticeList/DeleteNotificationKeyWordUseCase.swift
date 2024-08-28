//
//  DeleteNotificationKeyWordUseCase.swift
//  koin
//
//  Created by JOOMINKYUNG on 8/27/24.
//

import Combine
import Foundation

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
        if let existingKeyWords = CoreDataManager.shared.fetchEntities(objectType: NoticeKeyWordInfo.self, predicate: NSPredicate(format: "name == %@", keyWord.keyWord)) {
            for deletedKeyWord in existingKeyWords {
                CoreDataManager.shared.delete(deletedObject: deletedKeyWord)
            }
        }
    }
}
