//
//  AbTestService.swift
//  koin
//
//  Created by 김나훈 on 9/23/24.
//

import Alamofire
import Combine

protocol AbTestService {
    func assignAbTest(requestModel: AssignAbTestRequest) -> AnyPublisher<AssignAbTestResponse, ErrorResponse>
}

final class DefaultAbTestService: AbTestService {
    
    private let networkService = NetworkService()
    
    func assignAbTest(requestModel: AssignAbTestRequest) -> AnyPublisher<AssignAbTestResponse, ErrorResponse> {
        return networkService.requestWithResponse(api: AbTestAPI.assignAbTest(requestModel))
    }

    private func request<T: Decodable>(_ api: AbTestAPI) -> AnyPublisher<T, Error> {
        return AF.request(api)
            .publishDecodable(type: T.self)
            .value()
            .mapError { $0 as Error }
            .eraseToAnyPublisher()
    }
}
