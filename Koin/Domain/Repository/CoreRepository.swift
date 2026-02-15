//
//  CoreRepository.swift
//  koin
//
//  Created by 김나훈 on 10/1/24.
//

import Combine

protocol CoreRepository {
    func fetchVersion() -> AnyPublisher<ForceUpdateResponse, ErrorResponse>
    func fetBanner() -> AnyPublisher<BannerDto, ErrorResponse>
    func fetchClubCategories() -> AnyPublisher<ClubCategoriesDto, ErrorResponse>
    func fetchHotClubs() -> AnyPublisher<HotClubDto, ErrorResponse>
}
