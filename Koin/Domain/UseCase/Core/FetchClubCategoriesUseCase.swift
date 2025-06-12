//
//  FetchClubCategoriesUseCase.swift
//  koin
//
//  Created by 김나훈 on 6/13/25.
//

import Combine
import Foundation

protocol FetchClubCategoriesUseCase {
    func execute() -> AnyPublisher<ClubCategoriesDTO, Error>
}

final class DefaultFetchClubCategoriesUseCase: FetchClubCategoriesUseCase {
    private let coreRepository: CoreRepository
    
    init(coreRepository: CoreRepository) {
        self.coreRepository = coreRepository
    }
    
    func execute() -> AnyPublisher<ClubCategoriesDTO, Error> {
        return coreRepository.fetchClubCategories()
    }
}
