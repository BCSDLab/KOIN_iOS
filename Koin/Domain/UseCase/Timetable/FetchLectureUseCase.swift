//
//  FetchLectureUseCase.swift
//  koin
//
//  Created by 김나훈 on 11/20/24.
//

import Combine

protocol FetchLectureUseCase {
    func execute(frameId: Int) -> AnyPublisher<LectureDTO, ErrorResponse>
}

final class DefaultFetchLectureUseCase: FetchLectureUseCase {
    
    private let timetableRepository: TimetableRepository
    
    init(timetableRepository: TimetableRepository) {
        self.timetableRepository = timetableRepository
    }
    
    func execute(frameId: Int) -> AnyPublisher<LectureDTO, ErrorResponse> {
        return timetableRepository.fetchLecture(frameId: frameId)
    }
    
}
