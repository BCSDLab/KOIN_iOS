//
//  FetchBannerUseCase.swift
//  koin
//
//  Created by 김나훈 on 4/1/25.
//

import Combine
import Foundation

protocol FetchBannerUseCase {
    func execute() -> AnyPublisher<BannerDto, Error>
}

final class DefaultFetchBannerUseCase: FetchBannerUseCase {
    private let coreRepository: CoreRepository
    
    init(coreRepository: CoreRepository) {
        self.coreRepository = coreRepository
    }
    
    func execute() -> AnyPublisher<BannerDto, Error> {
        return coreRepository.fetBanner()
    }
}
