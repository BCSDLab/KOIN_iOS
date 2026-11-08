//
//  DefaultAbTestRepository.swift
//  koin
//
//  Created by 김나훈 on 10/2/24.
//

import Combine

final class DefaultAbTestRepository: AbTestRepository {
    
    private let service: AbTestService
    
    init(service: AbTestService) {
        self.service = service
    }
    
    func assignAbTest(requestModel: AssignAbTestRequest) -> AnyPublisher<AssignAbTestResponse, ErrorResponse> {
        if let cachedResponse = cachedAssignAbTestResponse {
            return Just(cachedResponse)
                .setFailureType(to: ErrorResponse.self)
                .eraseToAnyPublisher()
        }
        return service.assignAbTest(requestModel: requestModel)
    }
}

extension DefaultAbTestRepository {
    /// 이전 실험이 같은 키에 남긴 값은 `UserAssignType`으로 변환되지 않으므로 캐시 미스로 처리한다.
    private var cachedAssignAbTestResponse: AssignAbTestResponse? {
        guard let variableName = KeychainWorker.shared.read(key: .variableName).flatMap(UserAssignType.init(rawValue:)),
              let accessHistoryId = KeychainWorker.shared.read(key: .accessHistoryId).flatMap(Int.init) else {
            return nil
        }
        return AssignAbTestResponse(variableName: variableName, accessHistoryId: accessHistoryId)
    }
}
