//
//  FetchFramesUseCase.swift
//  koin
//
//  Created by 김나훈 on 12/10/24.
//

import Combine

protocol FetchFramesUseCase {
    func execute() -> AnyPublisher<[FrameData], ErrorResponse>
}

final class DefaultFetchFramesUseCase: FetchFramesUseCase {
    
    private let timetableRepository: TimetableRepository
    
    init(timetableRepository: TimetableRepository) {
        self.timetableRepository = timetableRepository
    }
    
    func execute() -> AnyPublisher<[FrameData], ErrorResponse> {
        return timetableRepository.fetchAllFrames()
            .map { semestersDTO in
                var frameDataList = semestersDTO.toDomain()
                frameDataList.sort { $0.semester > $1.semester }
                return frameDataList
            }
            .eraseToAnyPublisher()
    }
}
