//
//  CoreService.swift
//  koin
//
//  Created by 김나훈 on 10/1/24.
//

import Alamofire
import Combine

protocol CoreService {
    func fetchVersion() -> AnyPublisher<ForceUpdateResponse, Error>
    func fetchBanner() -> AnyPublisher<BannerDto, Error>
    func fetchClubCategories() -> AnyPublisher<ClubCategoriesDto, Error>
    func fetchHotClubs() -> AnyPublisher<HotClubDto, Error>
}

final class DefaultCoreService: CoreService {
    
    private let networkService = NetworkService()
    
    func fetchVersion() -> AnyPublisher<ForceUpdateResponse, Error> {
        return networkService.requestWithResponse(api: CoreAPI.checkVersion)
    }
    
    func fetchBanner() -> AnyPublisher<BannerDto, Error> {
        return networkService.requestWithResponse(api: CoreAPI.fetchBanner)
    }
    
    func fetchClubCategories() -> AnyPublisher<ClubCategoriesDto, Error> {
        return networkService.requestWithResponse(api: CoreAPI.fetchClubCategories)
    }
    
    func fetchHotClubs() -> AnyPublisher<HotClubDto, Error> {
        return networkService.requestWithResponse(api: CoreAPI.fetchHotClubs)
    }
}
