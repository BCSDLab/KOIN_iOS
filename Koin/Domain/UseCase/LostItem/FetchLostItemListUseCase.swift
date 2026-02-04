//
//  FetchLostItemListUseCase.swift
//  koin
//
//  Created by 홍기정 on 1/21/26.
//

import Foundation
import Combine

protocol FetchLostItemListUseCase {
    func execute(requestModel: FetchLostItemListRequest) -> AnyPublisher<LostItemList, Error>
}

final class DefaultFetchLostItemListUseCase: FetchLostItemListUseCase {
    
    private let repository: LostItemRepository
    
    init(repository: LostItemRepository) {
        self.repository = repository
    }
    
    func execute(requestModel: FetchLostItemListRequest) -> AnyPublisher<LostItemList, Error> {
        return repository.fetchLostItemList(requestModel: requestModel)
    }
}
