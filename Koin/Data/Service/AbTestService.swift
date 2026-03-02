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
    
    private let networkService = NetworkService.shared
    
    func assignAbTest(requestModel: AssignAbTestRequest) -> AnyPublisher<AssignAbTestResponse, ErrorResponse> {
        if KeychainWorker.shared.read(key: .accessHistoryId) == nil {
            return self.assignAbTestToken()
                .flatMap { _ in
                    self.assignAbTest(requestModel: requestModel)
                }
                .eraseToAnyPublisher()
        }
        
        // 키체인이 있는 경우 API 요청
        return networkService.requestWithResponse(api: AbTestAPI.assignAbTest(requestModel))
            .handleEvents(receiveOutput: { response in
                // KeyChain에 값 저장
                KeychainWorker.shared.create(key: .accessHistoryId, token: String(response.accessHistoryId))
                KeychainWorker.shared.create(key: .variableName, token: response.variableName.rawValue)
            })
            .eraseToAnyPublisher()
    }
    
    private func assignAbTestToken() -> AnyPublisher<Void, ErrorResponse> {
        return networkService.requestWithResponse(api: AbTestAPI.assignAbTestToken)
            .handleEvents(receiveOutput: { (response: AssignAbTestTokenResponse) in
                KeychainWorker.shared.create(key: .accessHistoryId, token: String(response.accessHistoryId))
            })
            .map { _ in () }
            .eraseToAnyPublisher()
    }
}
