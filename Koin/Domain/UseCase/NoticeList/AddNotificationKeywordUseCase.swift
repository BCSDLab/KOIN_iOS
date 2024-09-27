//
//  AddNotificationKeywordUseCase.swift
//  koin
//
//  Created by JOOMINKYUNG on 8/24/24.
//

import Combine

protocol AddNotificationKeywordUseCase {
    func execute(keyword: NoticeKeywordDTO, myKeywords: [NoticeKeywordDTO]) -> AnyPublisher<(NoticeKeywordDTO?, AddNoticeKeywordType), ErrorResponse>
}

final class DefaultAddNotificationKeywordUseCase: AddNotificationKeywordUseCase {
    private let noticeListRepository: NoticeListRepository
    
    init(noticeListRepository: NoticeListRepository) {
        self.noticeListRepository = noticeListRepository
    }
    
    func execute(keyword: NoticeKeywordDTO, myKeywords: [NoticeKeywordDTO]) -> AnyPublisher<(NoticeKeywordDTO?, AddNoticeKeywordType), ErrorResponse> {
        var addKeywordResult: AddNoticeKeywordType = .success

        if myKeywords.contains(where: { $0.keyword == keyword.keyword }) {
            addKeywordResult = .sameKeyword
        }
        else if keyword.keyword.count < 2 || keyword.keyword.count > 10 {
            addKeywordResult = .notInRange
        }
        else if myKeywords.count > 9 {
            addKeywordResult = .exceedNumber
        }
        
        if addKeywordResult != .success {
            return Just((nil, addKeywordResult))
                .setFailureType(to: ErrorResponse.self)
                .eraseToAnyPublisher()
        }
        
        return noticeListRepository.createNotificationKeyword(requestModel: keyword).map {
            ($0, addKeywordResult)
        }.eraseToAnyPublisher()
    }
}
