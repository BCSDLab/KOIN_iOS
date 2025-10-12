//
//  DeleteCartMenuItemUseCase.swift
//  koin
//
//  Created by 홍기정 on 10/12/25.
//

import Foundation
import Combine

protocol DeleteCartMenuItemUseCase {
    func execute(cartMenuItemId: Int) -> AnyPublisher<Void, ErrorResponse>
}

final class DefaultDeleteCartMenuItemUseCase: DeleteCartMenuItemUseCase {
    
    let repository: OrderShopRepository
    
    init(repository: OrderShopRepository) {
        self.repository = repository
    }
    
    func execute(cartMenuItemId: Int) -> AnyPublisher<Void, ErrorResponse> {
        return repository.deleteCartMenuItem(cartMenuItemId: cartMenuItemId)
            .eraseToAnyPublisher()
    }
}
