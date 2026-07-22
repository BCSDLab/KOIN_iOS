//
//  FetchEventCountUseCase.swift
//  koin
//
//  Created by 홍기정 on 6/5/26.
//

import Foundation
import Combine

protocol FetchEventCountUseCase {
    func execute() -> AnyPublisher<Int, ErrorResponse>
}

final class DefaultFetchEventCountUseCase: FetchEventCountUseCase {

    private let shopRepository: ShopRepository

    init(shopRepository: ShopRepository) {
        self.shopRepository = shopRepository
    }

    func execute() -> AnyPublisher<Int, ErrorResponse> {
        shopRepository.fetchEventCount()
    }
}
