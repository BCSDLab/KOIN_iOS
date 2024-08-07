//
//  FetchLandListUseCase.swift
//  koin
//
//  Created by 김나훈 on 6/23/24.
//

import Combine

protocol FetchLandListUseCase {
    func execute() -> AnyPublisher<[LandItem], Error>
}

final class DefaultFetchLandListUseCase: FetchLandListUseCase {
    
    private let landRepository: LandRepository
    
    init(landRepository: LandRepository) {
        self.landRepository = landRepository
    }
    
    func execute() -> AnyPublisher<[LandItem], Error> {
        return landRepository.fetchLandList().map { landDTO in
            landDTO.lands?.map { $0.toDomain() } ?? []
        }.eraseToAnyPublisher()
    }
}
