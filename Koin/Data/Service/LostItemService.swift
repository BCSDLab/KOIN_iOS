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
    
    private func request<T: Decodable>(_ api: LostItemAPI) -> AnyPublisher<T, Error> {
        return AF.request(api)
            .publishDecodable(type: T.self)
            .value()
            .mapError { $0 as Error }
            .eraseToAnyPublisher()
    }
}
