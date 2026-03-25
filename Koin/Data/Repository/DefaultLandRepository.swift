//
//  DefaultLandRepository.swift
//  koin
//
//  Created by 김나훈 on 6/23/24.
//

import Combine

final class DefaultLandRepository: LandRepository {
    
    private let service: LandService
    
    init(service: LandService) {
        self.service = service
    }
    
    func fetchLandList() -> AnyPublisher<LandDto, ErrorResponse> {
        return service.fetchLandList()
    }
    
    func fetchLandDetail(requestModel: FetchLandDetailRequest) -> AnyPublisher<LandDetailDto, ErrorResponse> {
        return service.fetchLandDetail(requestModel: requestModel)
    }
    
}
