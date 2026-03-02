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
    func fetchLostItemList(requestModel: FetchLostItemListRequest) -> AnyPublisher<LostItemListDto, ErrorResponse>
    func fetchLostItemData(id: Int) -> AnyPublisher<LostItemDataDto, ErrorResponse>
    func changeLostItemState(id: Int) -> AnyPublisher<Void, ErrorResponse>
    func deleteLostItem(id: Int) -> AnyPublisher<Void, ErrorResponse>
    func updateLostItem(id: Int, requestModel: UpdateLostItemRequest) -> AnyPublisher<LostItemDataDto, ErrorResponse>
    func fetchLostItemStats() -> AnyPublisher<LostItemStatsDto, ErrorResponse>
}

final class DefaultLostItemService: LostItemService {
    
    private let networkService = NetworkService.shared
    
    func fetchLostItemList(requestModel: FetchLostItemListRequest) -> AnyPublisher<LostItemListDto, ErrorResponse> {
        return networkService.requestWithResponse(api: LostItemAPI.fetchLostItemList(requestModel))
    }
    
    func fetchLostItemData(id: Int) -> AnyPublisher<LostItemDataDto, ErrorResponse> {
        return networkService.requestWithResponse(api: LostItemAPI.fetchLostItemData(id))
    }
    
    func changeLostItemState(id: Int) -> AnyPublisher<Void, ErrorResponse> {
        return networkService.request(api: LostItemAPI.changeListItemState(id))
    }
    
    func deleteLostItem(id: Int) -> AnyPublisher<Void, ErrorResponse> {
        return networkService.request(api: LostItemAPI.deleteLostItem(id))
    }
    
    func updateLostItem(id: Int, requestModel: UpdateLostItemRequest) -> AnyPublisher<LostItemDataDto, ErrorResponse> {
        return networkService.requestWithResponse(api: LostItemAPI.updateLostItem((id, requestModel)))
    }
    
    func fetchLostItemStats() -> AnyPublisher<LostItemStatsDto, ErrorResponse> {
        return networkService.requestWithResponse(api: LostItemAPI.fetchLostItemStats)
    }
}
