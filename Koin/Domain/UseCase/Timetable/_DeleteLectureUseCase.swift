//
//  _DeleteLectureUseCase.swift
//  koin
//
//  Created by 김나훈 on 11/21/24.
//


import Combine

protocol _DeleteLectureUseCase {
    func execute(id: Int) -> AnyPublisher<Void, ErrorResponse>
}

final class _DefaultDeleteLectureUseCase: _DeleteLectureUseCase {
    
    private let timetableRepository: TimetableRepository
    
    init(timetableRepository: TimetableRepository) {
        self.timetableRepository = timetableRepository
    }
    
    func execute(id: Int) -> AnyPublisher<Void, ErrorResponse> {
        return timetableRepository.deleteLecture(id: id)
    }
    
}
