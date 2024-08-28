//
//  FetchRecommendedKeyWordUseCase.swift
//  koin
//
//  Created by JOOMINKYUNG on 8/28/24.
//

import Combine

protocol FetchRecommendedKeyWordUseCase {
    func execute() -> AnyPublisher<[NoticeKeyWordDTO], Error>
}

final class DefaultFetchRecommendedKeyWordUseCase: FetchRecommendedKeyWordUseCase {
    private let noticeListRepository: NoticeListRepository
    
    init(noticeListRepository: NoticeListRepository) {
        self.noticeListRepository = noticeListRepository
    }
    
    func execute() -> AnyPublisher<[NoticeKeyWordDTO], Error> {
        return testData()
    }
    
    private func testData() -> AnyPublisher<[NoticeKeyWordDTO], Error> {
        let data = [
                NoticeKeyWordDTO(id: 1, keyWord: "교환"),
                NoticeKeyWordDTO(id: 2, keyWord: "장학"),
                NoticeKeyWordDTO(id: 3, keyWord: "학사"),
                NoticeKeyWordDTO(id: 4, keyWord: "근장"),
                NoticeKeyWordDTO(id: 5, keyWord: "졸업"),
            ]
        return Just(data)
            .setFailureType(to: Error.self)
            .eraseToAnyPublisher()
    }
}
