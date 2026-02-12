//
//  LostItemService.swift
//  koin
//
//  Created by 홍기정 on 1/21/26.
//

import Foundation
import Combine
import Alamofire

protocol LostItemService {
    func fetchLostItemList(requestModel: FetchLostItemListRequest) -> AnyPublisher<LostItemListDto, Error>
    func fetchLostItemData(id: Int) -> AnyPublisher<LostItemDataDto, Error>
    func changeLostItemState(id: Int) -> AnyPublisher<Void, ErrorResponse>
    func deleteLostItem(id: Int) -> AnyPublisher<Void, Error>
    func updateLostItem(id: Int, requestModel: UpdateLostItemRequest) -> AnyPublisher<LostItemDataDto, ErrorResponse>
    func fetchLostItemStats() -> AnyPublisher<LostItemStatsDto, Error>
}

final class DefaultLostItemService: LostItemService {
    
    private let networkService = NetworkService()
    
    func fetchLostItemList(requestModel: FetchLostItemListRequest) -> AnyPublisher<LostItemListDto, Error> {
        return networkService.requestWithResponse(api: LostItemAPI.fetchLostItemList(requestModel))
    }
    
    func fetchLostItemData(id: Int) -> AnyPublisher<LostItemDataDto, Error> {
        return networkService.requestWithResponse(api: LostItemAPI.fetchLostItemData(id))
    }
    
    func changeLostItemState(id: Int) -> AnyPublisher<Void, ErrorResponse> {
        return networkService.request(api: LostItemAPI.changeListItemState(id))
    }
    
    func deleteLostItem(id: Int) -> AnyPublisher<Void, Error> {
        return networkService.request(api: LostItemAPI.deleteLostItem(id))
    }
    
    func updateLostItem(id: Int, requestModel: UpdateLostItemRequest) -> AnyPublisher<LostItemDataDto, ErrorResponse> {
        return networkService.requestWithResponse(api: LostItemAPI.updateLostItem((id, requestModel)))
    }
    
    func fetchLostItemStats() -> AnyPublisher<LostItemStatsDto, Error> {
        return networkService.requestWithResponse(api: LostItemAPI.fetchLostItemStats)
    }
}
