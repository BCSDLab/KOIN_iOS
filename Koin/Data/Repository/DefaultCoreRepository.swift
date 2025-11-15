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
    
    func fetBanner() -> AnyPublisher<BannerDto, Error> {
        return service.fetchBanner()
    }
    func fetchClubCategories() -> AnyPublisher<ClubCategoriesDto, Error> {
        return service.fetchClubCategories()
    }
    
    func fetchHotClubs() -> AnyPublisher<HotClubDto, Error> {
        return service.fetchHotClubs()
    }
    
}
