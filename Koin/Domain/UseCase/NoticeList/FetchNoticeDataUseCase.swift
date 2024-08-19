//
//  FetchNoticeDataUseCase.swift
//  koin
//
//  Created by JOOMINKYUNG on 8/19/24.
//

import Combine
import Foundation

protocol FetchNoticeDataUseCase {
    //func fetchNoticeData(request: FetchNoticeDataRequest) -> AnyPublisher<[NoticeArticleDTO], Error>
}

final class DefaultFetchNoticedataUseCase: FetchNoticeDataUseCase {
    let noticeListRepository: NoticeListRepository
    
    init(noticeListRepository: NoticeListRepository) {
        self.noticeListRepository = noticeListRepository
    }
    
    /* func fetchNoticeData(request: FetchNoticeDataRequest) -> AnyPublisher<[NoticeArticleDTO], any Error> {
        
    } */ 
}
