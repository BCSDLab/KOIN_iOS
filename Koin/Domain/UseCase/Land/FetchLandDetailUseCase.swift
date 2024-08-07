//
//  FetchLandDetailUseCase.swift
//  koin
//
//  Created by 김나훈 on 6/23/24.
//

import Combine

protocol FetchLandDetailUseCase {
    func execute(landId: Int) -> AnyPublisher<LandDetailItem, Error>
}

final class DefaultFetchLandDetailUseCase: FetchLandDetailUseCase {
    
    private let landRepository: LandRepository
    
    init(landRepository: LandRepository) {
        self.landRepository = landRepository
    }
    
    func execute(landId: Int) -> AnyPublisher<LandDetailItem, Error> {
        return landRepository.fetchLandDetail(requestModel: FetchLandDetailRequest(id: landId)).map { landDetailDTO in
            landDetailDTO.toDomain()
        }.eraseToAnyPublisher()
    }
}
