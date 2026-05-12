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

final class DefaultFetchLostItemKeywordSuggestionUseCase: FetchLostItemKeywordSuggestionUseCase {
    
    private let repository: LostItemRepository
    
    init(repository: LostItemRepository) {
        self.repository = repository
    }
    
    func execute() -> AnyPublisher<[String], ErrorResponse> {
        return repository.fetchKeywordSuggestion()
    }
}
