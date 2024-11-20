//
//  DeleteLectureUseCase.swift
//  koin
//
//  Created by 김나훈 on 11/20/24.
//

import Combine

protocol DeleteLectureUseCase {
    func execute(frameId: Int, lectureId: Int) -> AnyPublisher<Void, ErrorResponse>
}

final class DefaultDeleteLectureUseCase: DeleteLectureUseCase {
    
    private let timetableRepository: TimetableRepository
    
    init(timetableRepository: TimetableRepository) {
        self.timetableRepository = timetableRepository
    }
    
    func execute(frameId: Int, lectureId: Int) -> AnyPublisher<Void, ErrorResponse> {
        return timetableRepository.deleteLecture(frameId: frameId, lectureId: lectureId)
    }
    
}
