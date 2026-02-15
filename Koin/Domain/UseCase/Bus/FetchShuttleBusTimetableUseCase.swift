//
//  FetchShuttleBusTimetableUseCase.swift
//  koin
//
//  Created by JOOMINKYUNG on 12/8/24.
//

import Combine

protocol FetchShuttleBusTimetableUseCase {
    func execute(id: String) -> AnyPublisher<ShuttleBusTimetable, ErrorResponse>
}

final class DefaultFetchShuttleBusTimetableUseCase: FetchShuttleBusTimetableUseCase {
    
    private let repository: BusRepository
    
    init(repository: BusRepository) {
        self.repository = repository
    }
    
    func execute(id: String) -> AnyPublisher<ShuttleBusTimetable, ErrorResponse> {
        return repository.fetchShuttleBusTimetable(id: id)
    }
}
