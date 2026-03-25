//
//  FetchLostItemDataUseCase.swift
//  koin
//
//  Created by 홍기정 on 1/22/26.
//

import Foundation
import Combine

protocol FetchLostItemDataUseCase {
    func execute(id: Int) -> AnyPublisher<LostItemData, ErrorResponse>
}

final class DefaultFetchLostItemDataUseCase: FetchLostItemDataUseCase {
    
    private let repository: LostItemRepository
    
    init(repository: LostItemRepository) {
        self.repository = repository
    }
    
    func execute(id: Int) -> AnyPublisher<LostItemData, ErrorResponse> {
        return repository.fetchLostItemData(id: id)
    }
}
