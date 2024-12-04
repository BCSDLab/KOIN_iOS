//
//  DeleteSemesterUseCase.swift
//  koin
//
//  Created by 김나훈 on 11/21/24.
//

import Combine

protocol DeleteSemesterUseCase {
    func execute(semester: String) -> AnyPublisher<Void, ErrorResponse>
}

final class DefaultDeleteSemesterUseCase: DeleteSemesterUseCase {
    
    private let timetableRepository: TimetableRepository
    
    init(timetableRepository: TimetableRepository) {
        self.timetableRepository = timetableRepository
    }
    
    func execute(semester: String) -> AnyPublisher<Void, ErrorResponse> {
        return timetableRepository.deleteSemester(semester: semester)
    }
    
}
