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
        return request(.fetchLostItemList(requestModel))
    }
    
    func fetchLostItemData(id: Int) -> AnyPublisher<LostItemDataDto, Error> {
        return request(.fetchLostItemData(id))
    }
    
    func changeLostItemState(id: Int) -> AnyPublisher<Void, ErrorResponse> {
        return networkService.request(api: LostItemAPI.changeListItemState(id))
            .catch { [weak self] error -> AnyPublisher<Void, ErrorResponse> in
                guard let self = self else { return Fail(error: error).eraseToAnyPublisher() }
                if error.code == "401" {
                    return self.networkService.refreshToken()
                        .flatMap { _ in self.networkService.request(api: LostItemAPI.changeListItemState(id)) }
                        .eraseToAnyPublisher()
                } else {
                    return Fail(error: error).eraseToAnyPublisher()
                }
            }
            .eraseToAnyPublisher()
    }
    
    func deleteLostItem(id: Int) -> AnyPublisher<Void, Error> {
        return request(.deleteLostItem(id))
    }
    
    func updateLostItem(id: Int, requestModel: UpdateLostItemRequest) -> AnyPublisher<LostItemDataDto, ErrorResponse> {
        return networkService.requestWithResponse(api: LostItemAPI.updateLostItem((id, requestModel)))
            .catch { [weak self] error -> AnyPublisher<LostItemDataDto, ErrorResponse> in
                guard let self = self else { return Fail(error: error).eraseToAnyPublisher() }
                if error.code == "401" {
                    return self.networkService.refreshToken()
                        .flatMap { _ in self.networkService.requestWithResponse(api: LostItemAPI.updateLostItem((id, requestModel))) }
                        .eraseToAnyPublisher()
                } else {
                    return Fail(error: error).eraseToAnyPublisher()
                }
            }
            .eraseToAnyPublisher()
    }
    
    func fetchLostItemStats() -> AnyPublisher<LostItemStatsDto, Error> {
        return request(LostItemAPI.fetchLostItemStats)
    }
    
    private func request<T: Decodable>(_ api: LostItemAPI) -> AnyPublisher<T, Error> {
        return AF.request(api)
            .publishDecodable(type: T.self)
            .value()
            .mapError { $0 as Error }
            .eraseToAnyPublisher()
    }
    
    private func request(_ api: LostItemAPI) -> AnyPublisher<Void, Error> {
        return AF.request(api)
            .validate()
            .publishData()
            .value()
            .map { _ in }
            .mapError { $0 as Error }
            .eraseToAnyPublisher()
    }
}
