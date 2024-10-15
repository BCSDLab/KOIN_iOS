//
//  AbTestRepository.swift
//  koin
//
//  Created by 김나훈 on 9/23/24.
//

import Combine

protocol AbTestRepository {
    func assignAbTest(requestModel: AssignAbTestRequest) -> AnyPublisher<AssignAbTestResponse, ErrorResponse>
}
