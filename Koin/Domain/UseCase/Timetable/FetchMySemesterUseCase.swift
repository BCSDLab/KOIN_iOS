//
//  FetchMySemesterUseCase.swift
//  koin
//
//  Created by 김나훈 on 11/20/24.
//

import Combine

protocol FetchMySemesterUseCase {
    func execute() -> AnyPublisher<MySemesterDTO, ErrorResponse>
}

final class DefaultFetchMySemesterUseCase: FetchMySemesterUseCase {
    
    private let timetableRepository: TimetableRepository
    
    init(timetableRepository: TimetableRepository) {
        self.timetableRepository = timetableRepository
    }
    
    func execute() -> AnyPublisher<MySemesterDTO, ErrorResponse> {
        return timetableRepository.fetchMySemester()
    }
    
}
