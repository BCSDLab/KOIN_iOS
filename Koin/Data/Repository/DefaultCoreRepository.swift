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
    
    func fetchVersion() -> AnyPublisher<ForceUpdateResponse, ErrorResponse> {
        return service.fetchVersion()
    }
    
    func fetBanner() -> AnyPublisher<BannerDto, ErrorResponse> {
        return service.fetchBanner()
    }
    func fetchClubCategories() -> AnyPublisher<ClubCategoriesDto, ErrorResponse> {
        return service.fetchClubCategories()
    }
    
    func fetchHotClubs() -> AnyPublisher<HotClubDto, ErrorResponse> {
        return service.fetchHotClubs()
    }
    
}
