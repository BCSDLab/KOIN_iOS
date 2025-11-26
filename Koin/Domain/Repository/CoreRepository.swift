//
//  CoreRepository.swift
//  koin
//
//  Created by 김나훈 on 10/1/24.
//

import Combine

protocol CoreRepository {
    func fetchVersion() -> AnyPublisher<ForceUpdateResponse, Error>
    func fetBanner() -> AnyPublisher<BannerDto, Error>
    func fetchClubCategories() -> AnyPublisher<ClubCategoriesDto, Error>
    func fetchHotClubs() -> AnyPublisher<HotClubDto, Error>
}
