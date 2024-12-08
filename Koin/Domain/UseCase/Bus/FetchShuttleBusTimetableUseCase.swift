//
//  FetchShuttleBusTimetableUseCase.swift
//  koin
//
//  Created by JOOMINKYUNG on 12/8/24.
//

import Combine
import Foundation

protocol FetchShuttleBusTimetableUseCase {
    func execute(id: String) -> AnyPublisher<ShuttleBusTimetableDTO, Error>
}

final class DefaultFetchShuttleBusTimetableUseCase: FetchShuttleBusTimetableUseCase {
    let repository: BusRepository
    
    init(repository: BusRepository) {
        self.repository = repository
    }
    
    func execute(id: String) -> AnyPublisher<ShuttleBusTimetableDTO, Error> {
        return repository.fetchShuttleBusTimetable(id: id)
    }
}
