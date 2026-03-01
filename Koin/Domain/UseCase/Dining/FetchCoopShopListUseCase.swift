//
//  FetchCoopShopListUseCase.swift
//  koin
//
//  Created by 김나훈 on 7/19/24.
//

import Combine
import Foundation

protocol FetchCoopShopListUseCase {
    func execute() -> AnyPublisher<CoopShopData, Error>
}

final class DefaultFetchCoopShopListUseCase: FetchCoopShopListUseCase {
    
    private let diningRepository: DiningRepository
    
    init(diningRepository: DiningRepository) {
        self.diningRepository = diningRepository
    }
    
    func execute() -> AnyPublisher<CoopShopData, Error> {
        return diningRepository.fetchCoopShopList()
            .tryMap { coopShopDtos -> CoopShopData in
                return coopShopDtos.toDomain()
            }
            .eraseToAnyPublisher()
    }
    
}
