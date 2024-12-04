//
//  PostLectureUseCase.swift
//  koin
//
//  Created by 김나훈 on 11/20/24.
//

import Combine

protocol PostLectureUseCase {
    func execute(request: LectureRequest) -> AnyPublisher<[LectureData], ErrorResponse>
}

final class DefaultPostLectureUseCase: PostLectureUseCase {
    
    private let timetableRepository: TimetableRepository
    
    init(timetableRepository: TimetableRepository) {
        self.timetableRepository = timetableRepository
    }
    
    func execute(request: LectureRequest) -> AnyPublisher<[LectureData], ErrorResponse> {
        return timetableRepository.postLecture(request: request).map { $0.toDomain() }
            .eraseToAnyPublisher()
    }
    
}
