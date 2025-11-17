//
//  FetchSearchShopUseCase.swift
//  koin
//
//  Created by 홍기정 on 11/8/25.
//

import Foundation
import Combine

protocol FetchSearchShopUseCase {
    func execute(keyword: String) -> AnyPublisher<ShopSearch, Error>
}

final class DefaultFetchSearchShopUseCase: FetchSearchShopUseCase {
    private let repository: ShopRepository
    
    init(repository: ShopRepository) {
        self.repository = repository
    }
    
    func execute(keyword: String) -> AnyPublisher<ShopSearch, Error> {
        let requestModel = FetchShopSearchRequest(keyword: keyword)
        return repository.fetchSearchShop(requestModel: requestModel)
    }
}
