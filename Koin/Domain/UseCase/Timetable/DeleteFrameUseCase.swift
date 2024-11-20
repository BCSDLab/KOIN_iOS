//
//  DeleteFrameUseCase.swift
//  koin
//
//  Created by 김나훈 on 11/20/24.
//

import Combine

protocol DeleteFrameUseCase {
    func execute(id: Int) -> AnyPublisher<Void, ErrorResponse>
}

final class DefaultDeleteFrameUseCase: DeleteFrameUseCase {
    
    private let timetableRepository: TimetableRepository
    
    init(timetableRepository: TimetableRepository) {
        self.timetableRepository = timetableRepository
    }
    
    func execute(id: Int) -> AnyPublisher<Void, ErrorResponse> {
        return timetableRepository.deleteFrame(id: id)
    }
    
}
