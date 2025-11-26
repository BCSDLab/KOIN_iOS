//
//  ModifyFrameUseCase.swift
//  koin
//
//  Created by 김나훈 on 11/20/24.
//

import Combine

protocol ModifyFrameUseCase {
    func execute(frame: FrameDto) -> AnyPublisher<FrameDto, ErrorResponse>
}

final class DefaultModifyFrameUseCase: ModifyFrameUseCase {
    
    private let timetableRepository: TimetableRepository
    
    init(timetableRepository: TimetableRepository) {
        self.timetableRepository = timetableRepository
    }
    
    func execute(frame: FrameDto) -> AnyPublisher<FrameDto, ErrorResponse> {
        return timetableRepository.modifyFrame(frame: frame)
    }
    
}
