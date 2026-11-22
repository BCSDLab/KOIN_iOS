//
//  FetchLandListUseCase.swift
//  koin
//
//  Created by 김나훈 on 6/23/24.
//

import Combine

protocol FetchLandListUseCase {
    func execute() -> AnyPublisher<LandList, ErrorResponse>
}

final class DefaultFetchLandListUseCase: FetchLandListUseCase {
    
    private let landRepository: LandRepository
    
    init(landRepository: LandRepository) {
        self.landRepository = landRepository
    }
    
    func execute() -> AnyPublisher<LandList, ErrorResponse> {
        return landRepository.fetchLandList().map { landListDto in
            landListDto.toDomain()
        }.eraseToAnyPublisher()
    }
}
