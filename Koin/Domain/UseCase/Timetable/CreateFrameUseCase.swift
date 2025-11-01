//
//  CreateFrameUseCase.swift
//  koin
//
//  Created by 김나훈 on 11/20/24.
//

import Combine

protocol CreateFrameUseCase {
    func execute(semester: String) -> AnyPublisher<FrameDto, ErrorResponse>
}

final class DefaultCreateFrameUseCase: CreateFrameUseCase {
    
    private let timetableRepository: TimetableRepository
    
    init(timetableRepository: TimetableRepository) {
        self.timetableRepository = timetableRepository
    }
    
    func execute(semester: String) -> AnyPublisher<FrameDto, ErrorResponse> {
        return timetableRepository.createFrame(semester: semester)
    }
    
}
