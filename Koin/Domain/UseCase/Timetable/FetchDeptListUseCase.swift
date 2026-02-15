//
//  FetchDeptListUseCase.swift
//  koin
//
//  Created by 김나훈 on 7/22/24.
//

import Combine

protocol FetchDeptListUseCase {
    func execute() -> AnyPublisher<[String], ErrorResponse>
}

final class DefaultFetchDeptListUseCase: FetchDeptListUseCase {
    
    private let timetableRepository: TimetableRepository
    
    init(timetableRepository: TimetableRepository) {
        self.timetableRepository = timetableRepository
    }
    
    func execute() -> AnyPublisher<[String], ErrorResponse> {
        return timetableRepository.fetchDeptList().map { $0.map { $0.name } }.eraseToAnyPublisher()
    }
    
}
