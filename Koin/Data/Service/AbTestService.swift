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
        return networkService.requestWithResponse(api: AbTestAPI.assignAbTest(requestModel))
            .handleEvents(receiveOutput: { response in
                // KeyChain에 값 저장
                KeyChainWorker.shared.create(key: .accessHistoryId, token: String(response.accessHistoryId))
                KeyChainWorker.shared.create(key: .variableName, token: response.variableName.rawValue)
            })
            .catch { [weak self] error -> AnyPublisher<AssignAbTestResponse, ErrorResponse> in
                guard let self = self else { return Fail(error: error).eraseToAnyPublisher() }
                
                // 401 에러가 발생한 경우, 토큰 갱신 후 재시도
                if error.code == "401" && !retry {
                    return self.networkService.refreshToken()
                        .flatMap { _ in self.assignAbTest(requestModel: requestModel) } // 재시도
                        .catch { refreshError -> AnyPublisher<AssignAbTestResponse, ErrorResponse> in
                            return self.assignAbTest(requestModel: requestModel, retry: true)
                        }
                        .eraseToAnyPublisher()
                } else {
                    // 다른 에러는 그대로 반환
                    return Fail(error: error).eraseToAnyPublisher()
                }
            }
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
