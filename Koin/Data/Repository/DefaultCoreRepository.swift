//
//  DefaultCoreRepository.swift
//  koin
//
//  Created by 김나훈 on 10/1/24.
//

import Combine

final class DefaultCoreRepository: CoreRepository {
    
    private let service: CoreService
    
    init(service: CoreService) {
        self.service = service
    }
    
    func fetchVersion() -> AnyPublisher<ForceUpdateResponse, Error> {
        return service.fetchVersion()
    }
    
    func fetBanner() -> AnyPublisher<BannerDTO, Error> {
        return service.fetchBanner()
    }
    
}
