//
//  FetchSemesterUseCase.swift
//  koin
//
//  Created by 김나훈 on 11/20/24.
//

import Combine

protocol FetchSemesterUseCase {
    func execute() -> AnyPublisher<[SemesterDTO], Error>
}

final class DefaultFetchSemesterUseCase: FetchSemesterUseCase {
    
    private let timetableRepository: TimetableRepository
    
    init(timetableRepository: TimetableRepository) {
        self.timetableRepository = timetableRepository
    }
    
    func execute() -> AnyPublisher<[SemesterDTO], Error> {
        return timetableRepository.fetchSemester()
    }
    
}
