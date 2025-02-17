//
//  AbTestService.swift
//  koin
//
//  Created by 김나훈 on 9/23/24.
//

import Alamofire
import Combine

protocol AbTestService {
    func assignAbTest(requestModel: AssignAbTestRequest, retry: Bool) -> AnyPublisher<AssignAbTestResponse, ErrorResponse>
}

final class DefaultAbTestService: AbTestService {
    
    private let networkService = NetworkService()
    
    func assignAbTest(requestModel: AssignAbTestRequest, retry: Bool = false) -> AnyPublisher<AssignAbTestResponse, ErrorResponse> {
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
               .catch { error -> AnyPublisher<AssignAbTestResponse, ErrorResponse> in

                   if error.code == "401" && !retry {
                       return self.networkService.refreshToken()
                           .flatMap { _ in self.assignAbTest(requestModel: requestModel) } // 재시도
                           .catch { refreshError -> AnyPublisher<AssignAbTestResponse, ErrorResponse> in
                               return self.assignAbTest(requestModel: requestModel, retry: true)
                           }
                           .eraseToAnyPublisher()
                   } else {
                       return Fail(error: error).eraseToAnyPublisher()
                   }
               }
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
    
    private func request<T: Decodable>(_ api: AbTestAPI) -> AnyPublisher<T, Error> {
        return AF.request(api)
            .publishDecodable(type: T.self)
            .value()
            .mapError { $0 as Error }
            .eraseToAnyPublisher()
    }
}
