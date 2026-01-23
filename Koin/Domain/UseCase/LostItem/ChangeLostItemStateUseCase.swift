//
//  ChangeLostItemStateUseCase.swift
//  koin
//
//  Created by 홍기정 on 1/22/26.
//

import Foundation
import Combine

protocol ChangeLostItemStateUseCase {
    func execute(id: Int) -> AnyPublisher<Void, ErrorResponse>
}

final class DefaultChangeLostItemStateUseCase: ChangeLostItemStateUseCase {
    
    private let repository: LostItemRepository
    
    init(repository: LostItemRepository) {
        self.repository = repository
    }
    
    func execute(id: Int) -> AnyPublisher<Void, ErrorResponse> {
        return repository.changeLostItemState(id: id)
    }
}
