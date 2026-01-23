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
}

final class DefaultLostItemService: LostItemService {
    
    func fetchLostItemList(requestModel: FetchLostItemListRequest) -> AnyPublisher<LostItemListDto, Error> {
        return request(.fetchLostItemList(requestModel))
    }
    
    func fetchLostItemData(id: Int) -> AnyPublisher<LostItemDataDto, Error> {
        print(id)
        return request(.fetchLostItemData(id))
    }
    
    private func request<T: Decodable>(_ api: LostItemAPI) -> AnyPublisher<T, Error> {
        return AF.request(api)
            .publishDecodable(type: T.self)
            .value()
            .mapError { $0 as Error }
            .eraseToAnyPublisher()
    }
}
