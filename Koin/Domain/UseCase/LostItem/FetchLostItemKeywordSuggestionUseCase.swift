//
//  FetchLostItemKeywordSuggestionUseCase.swift
//  koin
//
//  Created by 홍기정 on 5/11/26.
//

import Foundation
import Combine

protocol FetchLostItemKeywordSuggestionUseCase {
    func execute() -> AnyPublisher<[String], ErrorResponse>
}

final class MockFetchLostItemKeywordSuggestionUseCase: FetchLostItemKeywordSuggestionUseCase {
    
    let suggestions: [String] = [
        "추천1", "추천2", "추천3"
    ]
    func execute() -> AnyPublisher<[String], ErrorResponse> {
        return Just(suggestions)
            .setFailureType(to: ErrorResponse.self)
            .eraseToAnyPublisher()
    }
}
