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
    
    func fetchLostItemData(id: Int) -> AnyPublisher<LostItemData, Error> {
        return service.fetchLostItemData(id: id)
            .map { $0.toDomain() }
            .eraseToAnyPublisher()
    }
    
    func changeLostItemState(id: Int) -> AnyPublisher<Void, ErrorResponse> {
        return service.changeLostItemState(id: id)
    }
    
    func deleteLostItem(id: Int) -> AnyPublisher<Void, Error> {
        return service.deleteLostItem(id: id)
    }
    
    func updateLostItem(id: Int, requestModel: UpdateLostItemRequest) -> AnyPublisher<LostItemData, ErrorResponse> {
        return service.updateLostItem(id: id, requestModel: requestModel)
            .map { $0.toDomain() }
            .eraseToAnyPublisher()
    }
    
    func fetchLostItemStats() -> AnyPublisher<LostItemStats, Error> {
        return service.fetchLostItemStats()
            .map { $0.toDomain() }
            .eraseToAnyPublisher()
    }
}
