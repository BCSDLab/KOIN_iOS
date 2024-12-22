//
//  FetchEmergencyNoticeUseCase.swift
//  koin
//
//  Created by JOOMINKYUNG on 12/8/24.
//

import Combine
import Foundation

protocol FetchEmergencyNoticeUseCase {
    func execute() -> AnyPublisher<BusNoticeDTO, Error>
}

final class DefaultFetchEmergencyNoticeUseCase: FetchEmergencyNoticeUseCase {
    let repository: BusRepository
    
    init(repository: BusRepository) {
        self.repository = repository
    }
    
    func execute() -> AnyPublisher<BusNoticeDTO, Error> {
        return repository.fetchEmergencyNotice().eraseToAnyPublisher()
    }
}
