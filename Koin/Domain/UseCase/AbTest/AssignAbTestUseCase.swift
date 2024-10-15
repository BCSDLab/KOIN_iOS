//
//  AssignAbTestUseCase.swift
//  koin
//
//  Created by 김나훈 on 9/23/24.
//

import Combine
import Foundation

protocol AssignAbTestUseCase {
    func execute(requestModel: AssignAbTestRequest) -> AnyPublisher<AssignAbTestResponse, ErrorResponse>
}

final class DefaultAssignAbTestUseCase: AssignAbTestUseCase {
    
    private let abTestRepository: AbTestRepository
    
    init(abTestRepository: AbTestRepository) {
        self.abTestRepository = abTestRepository
    }
    
    func execute(requestModel: AssignAbTestRequest) -> AnyPublisher<AssignAbTestResponse, ErrorResponse> {
        abTestRepository.assignAbTest(requestModel: requestModel)
    }
    
}
