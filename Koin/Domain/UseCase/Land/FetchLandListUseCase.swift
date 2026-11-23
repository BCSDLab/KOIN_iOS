//
//  FetchLandListUseCase.swift
//  koin
//
//  Created by 김나훈 on 6/23/24.
//

import Combine

protocol FetchLandListUseCase {
    func execute(query: String?) -> AnyPublisher<LandList, ErrorResponse>
}

final class DefaultFetchLandListUseCase: FetchLandListUseCase {
    
    private let landRepository: LandRepository
    
    init(landRepository: LandRepository) {
        self.landRepository = landRepository
    }
    
    func execute(query: String?) -> AnyPublisher<LandList, ErrorResponse> {
        return landRepository.fetchLandList(requestModel: FetchLandListRequest(query: query)).map { landListDto in
            landListDto.toDomain()
        }.eraseToAnyPublisher()
    }
}
