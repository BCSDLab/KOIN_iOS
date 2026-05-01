//
//  FetchCallVanRestriction.swift
//  koin
//
//  Created by 홍기정 on 4/8/26.
//

import Foundation
import Combine

protocol FetchCallVanRestrictionUseCase {
    func execute() -> AnyPublisher<CallVanRestriction, ErrorResponse>
}

final class DefaultFetchCallVanRestrictionUseCase: FetchCallVanRestrictionUseCase {
    
    private let repository: CallVanRepository
    
    init(repository: CallVanRepository) {
        self.repository = repository
    }
    
    func execute() -> AnyPublisher<CallVanRestriction, ErrorResponse> {
        return repository.fetchRestriction()
    }
}

