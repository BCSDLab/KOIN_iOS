//
//  FetchCallVanParticipants.swift
//  koin
//
//  Created by 홍기정 on 3/10/26.
//

import UIKit
import Combine

protocol FetchCallVanDataUseCase {
    func execute(postId: Int) -> AnyPublisher<CallVanData, ErrorResponse>
}


final class DefaultFetchCallVanDataUseCase: FetchCallVanDataUseCase {
    
    private let repository: CallVanRepository
    
    init(repository: CallVanRepository) {
        self.repository = repository
    }
    
    func execute(postId: Int) -> AnyPublisher<CallVanData, ErrorResponse> {
        return repository.fetchCallVanData(postId: postId)
    }
}
