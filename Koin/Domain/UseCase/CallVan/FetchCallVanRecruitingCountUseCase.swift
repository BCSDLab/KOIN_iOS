//
//  FetchCallVanRecruitingCountUseCase.swift
//  koin
//
//  Created by 홍기정 on 6/5/26.
//

import Foundation
import Combine

protocol FetchCallVanRecruitingCountUseCase {
    func execute() -> AnyPublisher<Int, ErrorResponse>
}

final class DefaultFetchCallVanRecruitingCountUseCase: FetchCallVanRecruitingCountUseCase {
    
    private let repository: CallVanRepository
    
    init(repository: CallVanRepository) {
        self.repository = repository
    }
    
    func execute() -> AnyPublisher<Int, ErrorResponse> {
        repository.fetchCallVanList(request: .init(state: .recruiting, limit: 1))
            .map { list in return list.totalCount }
            .eraseToAnyPublisher()
    }
}

