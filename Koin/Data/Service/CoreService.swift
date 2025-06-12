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
    func fetchBanner() -> AnyPublisher<BannerDTO, Error>
    func fetchClubCategories() -> AnyPublisher<ClubCategoriesDTO, Error>
    func fetchHotClubs() -> AnyPublisher<HotClubDTO, Error>
}

final class DefaultCoreService: CoreService {
    func fetchVersion() -> AnyPublisher<ForceUpdateResponse, Error> {
        return request(.checkVersion)
    }
    func fetchBanner() -> AnyPublisher<BannerDTO, Error> {
        return request(.fetchBanner)
    }
    func fetchClubCategories() -> AnyPublisher<ClubCategoriesDTO, Error> {
        return request(.fetchClubCategories)
    }
    
    func fetchHotClubs() -> AnyPublisher<HotClubDTO, Error> {
        return request(.fetchHotClubs)
    }

    private func request<T: Decodable>(_ api: CoreAPI) -> AnyPublisher<T, Error> {
        return AF.request(api)
            .publishDecodable(type: T.self)
            .value()
            .mapError { $0 as Error }
            .eraseToAnyPublisher()
    }
}
