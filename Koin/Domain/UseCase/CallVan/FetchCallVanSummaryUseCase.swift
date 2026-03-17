//
//  FetchCallVanSummaryUseCase.swift
//  koin
//
//  Created by 홍기정 on 3/17/26.
//

import Foundation
import Combine

protocol FetchCallVanSummaryUseCase {
    func execute(postId: Int) -> AnyPublisher<CallVanListPost, ErrorResponse>
}

final class DefaultFetchCallVanSummaryUseCase: FetchCallVanSummaryUseCase {
    
    private let repository: CallVanRepository
    
    init(repository: CallVanRepository) {
        self.repository = repository
    }
    
    func execute(postId: Int) -> AnyPublisher<CallVanListPost, ErrorResponse> {
        return repository.fetchCallVanSummary(postId: postId)
    }
}
