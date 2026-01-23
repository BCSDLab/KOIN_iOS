//
//  DefaultLostItemRepository.swift
//  koin
//
//  Created by 홍기정 on 1/21/26.
//

import Foundation
import Combine

final class DefaultLostItemRepository: LostItemRepository {
    
    private let service: LostItemService
    
    init(service: LostItemService) {
        self.service = service
    }
    
    func fetchLostItemList(requestModel: FetchLostItemListRequest) -> AnyPublisher<LostItemList, any Error> {
        return service.fetchLostItemList(requestModel: requestModel)
            .map { $0.toDomain() }
            .eraseToAnyPublisher()
    }
}
