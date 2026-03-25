//
//  LandService.swift
//  koin
//
//  Created by 김나훈 on 6/23/24.
//

import Alamofire
import Combine

protocol LandService {
    func fetchLandList() -> AnyPublisher<LandDto, ErrorResponse>
    func fetchLandDetail(requestModel: FetchLandDetailRequest) -> AnyPublisher<LandDetailDto, ErrorResponse>
}

final class DefaultLandService: LandService {
    
    private let networkService = NetworkService.shared
    
    func fetchLandList() -> AnyPublisher<LandDto, ErrorResponse> {
        return networkService.requestWithResponse(api: LandAPI.fetchLandList)
    }
    
    func fetchLandDetail(requestModel: FetchLandDetailRequest) -> AnyPublisher<LandDetailDto, ErrorResponse> {
        return networkService.requestWithResponse(api: LandAPI.fetchLandDetail(requestModel))
    }
}
