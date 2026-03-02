//
//  FetchEmergencyNoticeUseCase.swift
//  koin
//
//  Created by JOOMINKYUNG on 12/8/24.
//

import Combine
import Foundation

protocol FetchEmergencyNoticeUseCase {
    func execute() -> AnyPublisher<BusNoticeDto, ErrorResponse>
}

final class DefaultFetchEmergencyNoticeUseCase: FetchEmergencyNoticeUseCase {
    let repository: BusRepository
    
    init(repository: BusRepository) {
        self.repository = repository
    }
    
    func execute() -> AnyPublisher<BusNoticeDto, ErrorResponse> {
        return repository.fetchEmergencyNotice().eraseToAnyPublisher()
    }
}
