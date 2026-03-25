//
//  PostAllNotificationsReadUseCase.swift
//  koin
//
//  Created by 홍기정 on 3/15/26.
//

import Foundation
import Combine

protocol PostAllNotificationsReadUseCase {
    func execute() -> AnyPublisher<Void, ErrorResponse>
}

final class DefaultPostAllNotificationsReadUseCase: PostAllNotificationsReadUseCase {
    
    private let repository: CallVanRepository
    
    init(repository: CallVanRepository) {
        self.repository = repository
    }
    
    func execute() -> AnyPublisher<Void, ErrorResponse> {
        return repository.postAllNotificationsRead()
    }
}
