//
//  FetchFrameUseCase.swift
//  koin
//
//  Created by 김나훈 on 11/20/24.
//

import Combine

protocol FetchFrameUseCase {
    func execute(semester: String) -> AnyPublisher<[FrameDTO], ErrorResponse>
}

final class DefaultFetchFrameUseCase: FetchFrameUseCase {
    
    private let timetableRepository: TimetableRepository
    
    init(timetableRepository: TimetableRepository) {
        self.timetableRepository = timetableRepository
    }
    
    func execute(semester: String) -> AnyPublisher<[FrameDTO], ErrorResponse> {
        return timetableRepository.fetchFrame(semester: semester)
    }
    
}
