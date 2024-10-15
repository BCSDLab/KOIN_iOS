//
//  DiningService.swift
//  koin
//
//  Created by 김나훈 on 6/7/24.
//

import Alamofire
import Combine

protocol DiningService {
    func fetchDiningList(requestModel: FetchDiningListRequest, retry: Bool) -> AnyPublisher<[DiningDTO], ErrorResponse>
    func fetchCoopShopList() -> AnyPublisher<CoopShopDTO, Error>
    func diningLike(requestModel: DiningLikeRequest, isLiked: Bool) -> AnyPublisher<Void, ErrorResponse>
}

final class DefaultDiningService: DiningService {
    
    private let networkService = NetworkService()
    
    func fetchDiningList(requestModel: FetchDiningListRequest, retry: Bool = false) -> AnyPublisher<[DiningDTO], ErrorResponse> {
        return networkService.requestWithResponse(api: DiningAPI.fetchDiningList(requestModel))
            .catch { [weak self] error -> AnyPublisher<[DiningDTO], ErrorResponse> in
                guard let self = self else { return Fail(error: error).eraseToAnyPublisher() }
                if error.code == "401" && !retry {
                    return self.networkService.refreshToken()
                        .flatMap { _ in self.networkService.requestWithResponse(api: DiningAPI.fetchDiningList(requestModel)) }
                        .catch { refreshError -> AnyPublisher<[DiningDTO], ErrorResponse> in
                            return self.fetchDiningList(requestModel: requestModel, retry: true)
                        }
                        .eraseToAnyPublisher()
                } else {
                    return Fail(error: error).eraseToAnyPublisher()
                }
            }
            .eraseToAnyPublisher()
    }
    
    
    func fetchCoopShopList() -> AnyPublisher<CoopShopDTO, Error> {
        return request(.fetchCoopShopList)
    }
    
    func diningLike(requestModel: DiningLikeRequest, isLiked: Bool) -> AnyPublisher<Void, ErrorResponse> {
        return networkService.request(api: DiningAPI.diningLike(requestModel, isLiked))
            .catch { [weak self] error -> AnyPublisher<Void, ErrorResponse> in
                guard let self = self else { return Fail(error: error).eraseToAnyPublisher() }
                if error.code == "401" {
                    return self.networkService.refreshToken()
                        .flatMap { _ in self.networkService.request(api: DiningAPI.diningLike(requestModel, isLiked)) }
                        .eraseToAnyPublisher()
                } else {
                    return Fail(error: error).eraseToAnyPublisher()
                }
            }
            .eraseToAnyPublisher()
    }
    
    private func request<T: Decodable>(_ api: DiningAPI) -> AnyPublisher<T, Error> {
        return AF.request(api)
            .publishDecodable(type: T.self)
            .value()
            .mapError { $0 as Error }
            .eraseToAnyPublisher()
    }
}
