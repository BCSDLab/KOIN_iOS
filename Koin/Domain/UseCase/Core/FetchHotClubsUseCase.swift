//
//  FetchHotClubsUseCase.swift
//  koin
//
//  Created by 김나훈 on 6/13/25.
//

import Combine
import Foundation

protocol FetchHotClubsUseCase {
    func execute() -> AnyPublisher<HotClubDTO, Error>
}

final class DefaultFetchHotClubsUseCase: FetchHotClubsUseCase {
    private let coreRepository: CoreRepository
    
    init(coreRepository: CoreRepository) {
        self.coreRepository = coreRepository
    }
    
    func execute() -> AnyPublisher<HotClubDTO, Error> {
        return coreRepository.fetchHotClubs()
    }
}
