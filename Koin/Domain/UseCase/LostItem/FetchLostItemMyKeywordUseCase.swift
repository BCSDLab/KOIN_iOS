//
//  FetchLostItemMyKeywordUseCase.swift
//  koin
//
//  Created by 홍기정 on 5/11/26.
//

import Foundation
import Combine

protocol FetchLostItemMyKeywordUseCase {
    func execute() -> AnyPublisher<[String], ErrorResponse>
}

final class MockFetchLostItemMyKeywordUseCase: FetchLostItemMyKeywordUseCase {
    
    let keywords: [String] = [
        "내꺼1", "내꺼2", "내거3"
    ]
    func execute() -> AnyPublisher<[String], ErrorResponse> {
        return Just(keywords)
            .setFailureType(to: ErrorResponse.self)
            .eraseToAnyPublisher()
    }
}
