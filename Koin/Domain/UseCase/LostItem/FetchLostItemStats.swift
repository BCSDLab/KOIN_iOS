//
//  FetchLostItemStats.swift
//  koin
//
//  Created by 홍기정 on 1/24/26.
//

import Foundation
import Combine

protocol FetchLostItemStatsUseCase {
    func execute() -> AnyPublisher<LostItemStats, ErrorResponse>
}

final class DefaultFetchLostItemStatsUseCase: FetchLostItemStatsUseCase {
    
    private let repository: LostItemRepository
    
    init(repository: LostItemRepository) {
        self.repository = repository
    }
    
    func execute() -> AnyPublisher<LostItemStats, ErrorResponse> {
        return repository.fetchLostItemStats()
    }
}
