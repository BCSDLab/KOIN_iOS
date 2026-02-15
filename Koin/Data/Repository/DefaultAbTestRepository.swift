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
        return service.assignAbTest(requestModel: requestModel)
    }
}
