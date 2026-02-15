//
//  DeleteLostItemUseCase.swift
//  koin
//
//  Created by 홍기정 on 1/23/26.
//

import Foundation
import Combine

protocol DeleteLostItemUseCase {
    func execute(id: Int) -> AnyPublisher<Void, ErrorResponse>
}

final class DefaultDeleteLostItemUseCase: DeleteLostItemUseCase {
    
    private let repository: LostItemRepository
    
    init(repository: LostItemRepository) {
        self.repository = repository
    }
    
    func execute(id: Int) -> AnyPublisher<Void, ErrorResponse> {
        repository.deleteLostItem(id: id)
    }
}
