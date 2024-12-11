//
//  ModifyFrameUseCase.swift
//  koin
//
//  Created by 김나훈 on 11/20/24.
//

import Combine

protocol ModifyFrameUseCase {
    func execute(frame: FrameDTO) -> AnyPublisher<FrameDTO, ErrorResponse>
}

final class DefaultModifyFrameUseCase: ModifyFrameUseCase {
    
    private let timetableRepository: TimetableRepository
    
    init(timetableRepository: TimetableRepository) {
        self.timetableRepository = timetableRepository
    }
    
    func execute(frame: FrameDTO) -> AnyPublisher<FrameDTO, ErrorResponse> {
        return timetableRepository.modifyFrame(frame: frame)
    }
    
}
