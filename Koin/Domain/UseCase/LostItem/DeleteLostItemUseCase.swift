//
//  DeleteLostItemUseCase.swift
//  koin
//
//  Created by 홍기정 on 1/23/26.
//

import Foundation
import Combine

protocol DeleteLostItemUseCase {
    func execute(id: Int) -> AnyPublisher<Void, Error>
}

final class DefaultDeleteLostItemUseCase: DeleteLostItemUseCase {
    
    private let repository: LostItemRepository
    
    init(repository: LostItemRepository) {
        self.repository = repository
    }
    
    func execute(id: Int) -> AnyPublisher<Void, Error> {
        repository.deleteLostItem(id: id)
    }
}
