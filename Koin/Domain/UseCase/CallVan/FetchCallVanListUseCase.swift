//
//  FetchCallVanListUseCase.swift
//  koin
//
//  Created by 홍기정 on 3/5/26.
//

import Foundation
import Combine

protocol FetchCallVanListUseCase {
    func execute(request: CallVanListRequest) -> AnyPublisher<CallVanList, ErrorResponse>
}

final class DefaultFetchCallVanListUseCase: FetchCallVanListUseCase {
    
    private let repository: CallVanRepository
    
    init(repository: CallVanRepository) {
        self.repository = repository
    }
    
    func execute(request: CallVanListRequest) -> AnyPublisher<CallVanList, ErrorResponse> {
        repository.fetchCallVanList(request)
    }
}
