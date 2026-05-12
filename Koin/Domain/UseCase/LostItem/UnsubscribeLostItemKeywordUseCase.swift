//
//  UnsubscribeLostItemKeywordUseCase.swift
//  koin
//
//  Created by 홍기정 on 5/12/26.
//

import Foundation
import Combine

protocol UnsubscribeLostItemKeywordUseCase {
    func execute(id: Int) -> AnyPublisher<Void, ErrorResponse>
}

final class DefaultUnsubscribeLostItemKeywordUseCase: UnsubscribeLostItemKeywordUseCase {
    
    private let repository: LostItemRepository
    
    init(repository: LostItemRepository) {
        self.repository = repository
    }
    
    func execute(id: Int) -> AnyPublisher<Void, ErrorResponse> {
        return repository.unsubscribeKeyword(id: id)
    }
}
