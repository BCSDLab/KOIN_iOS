//
//  RollbackFrameUseCase.swift
//  koin
//
//  Created by 김나훈 on 12/10/24.
//

import Combine

protocol RollbackFrameUseCase {
    func execute(id: Int) -> AnyPublisher<[LectureData], ErrorResponse>
}

final class DefaultRollbackFrameUseCase: RollbackFrameUseCase {
    
    private let timetableRepository: TimetableRepository
    
    init(timetableRepository: TimetableRepository) {
        self.timetableRepository = timetableRepository
    }
    
    func execute(id: Int) -> AnyPublisher<[LectureData], ErrorResponse> {
        return timetableRepository.rollbackFrame(id: id).map { $0.toDomain() }.eraseToAnyPublisher()
    }
    
}
