//
//  FetchLostItemMyKeywordUseCase.swift
//  koin
//
//  Created by 홍기정 on 5/11/26.
//

import Foundation
import Combine

protocol FetchLostItemMyKeywordUseCase {
    func execute() -> AnyPublisher<LostItemKeywords, ErrorResponse>
}

final class DefaultFetchLostItemMyKeywordUseCase: FetchLostItemMyKeywordUseCase {
    
    private let repository: LostItemRepository
    
    init(repository: LostItemRepository) {
        self.repository = repository
    }
    
    func execute() -> AnyPublisher<LostItemKeywords, ErrorResponse> {
        return repository.fetchMyKeyword()
    }
}
