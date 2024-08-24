//
//  ChangeNotificationKeyWordUseCase.swift
//  koin
//
//  Created by JOOMINKYUNG on 8/24/24.
//

import Combine

protocol ChangeNotificationKeyWordUseCase {
    func createNotificationKeyWord(requestModel: NoticeKeyWordDTO) -> AnyPublisher<NoticeKeyWordDTO, ErrorResponse>
    func deleteNotificationKeyWord(requestModel: Int) -> AnyPublisher<Void, ErrorResponse>
}

final class DefaultChangeNotificationKeyWordUseCase: ChangeNotificationKeyWordUseCase {
    private let noticeListRepository: NoticeListRepository
    
    init(noticeListRepository: NoticeListRepository) {
        self.noticeListRepository = noticeListRepository
    }
    
    func createNotificationKeyWord(requestModel: NoticeKeyWordDTO) -> AnyPublisher<NoticeKeyWordDTO, ErrorResponse> {
        noticeListRepository.createNotificationKeyWord(requestModel: requestModel).eraseToAnyPublisher()
    }
    
    func deleteNotificationKeyWord(requestModel: Int) -> AnyPublisher<Void, ErrorResponse> {
        return noticeListRepository.deleteNotificationKeyWord(requestModel: requestModel).eraseToAnyPublisher()
    }
}
