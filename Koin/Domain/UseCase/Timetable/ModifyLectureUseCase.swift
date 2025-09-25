//
//  ModifyLectureUseCase.swift
//  koin
//
//  Created by 김나훈 on 11/20/24.
//

import Combine

protocol ModifyLectureUseCase {
    func execute(request: LectureRequest) -> AnyPublisher<LectureDto, ErrorResponse>
}

final class DefaultModifyLectureUseCase: ModifyLectureUseCase {
    
    private let timetableRepository: TimetableRepository
    
    init(timetableRepository: TimetableRepository) {
        self.timetableRepository = timetableRepository
    }
    
    func execute(request: LectureRequest) -> AnyPublisher<LectureDto, ErrorResponse> {
        return timetableRepository.modifyLecture(request: request)
    }
    
}
