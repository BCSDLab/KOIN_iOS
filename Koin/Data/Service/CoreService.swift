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
    func fetchVersion() -> AnyPublisher<ForceUpdateResponse, Error> {
        return request(.checkVersion)
    }
    func fetchBanner() -> AnyPublisher<BannerDto, Error> {
        return request(.fetchBanner)
    }
    func fetchClubCategories() -> AnyPublisher<ClubCategoriesDto, Error> {
        return request(.fetchClubCategories)
    }
    
    func fetchHotClubs() -> AnyPublisher<HotClubDto, Error> {
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
