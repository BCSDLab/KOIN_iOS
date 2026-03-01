//
//  LandService.swift
//  koin
//
//  Created by 김나훈 on 6/23/24.
//

import Alamofire
import Combine

protocol LandService {
    func fetchLandList() -> AnyPublisher<LandDto, Error>
    func fetchLandDetail(requestModel: FetchLandDetailRequest) -> AnyPublisher<LandDetailDto, Error>
}

final class DefaultLandService: LandService {
    
    func fetchLandList() -> AnyPublisher<LandDto, Error> {
        return request(.fetchLandList)
    }
    
    func fetchLandDetail(requestModel: FetchLandDetailRequest) -> AnyPublisher<LandDetailDto, Error> {
        return request(.fetchLandDetail(requestModel))
    }

    private func request<T: Decodable>(_ api: LandAPI) -> AnyPublisher<T, Error> {
        return AF.request(api)
            .publishDecodable(type: T.self)
            .value()
            .mapError { $0 as Error }
            .eraseToAnyPublisher()
    }
}
