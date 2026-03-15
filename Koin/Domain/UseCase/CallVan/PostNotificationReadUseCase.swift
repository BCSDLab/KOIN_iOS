//
//  PostNotificationReadUseCase.swift
//  koin
//
//  Created by 홍기정 on 3/15/26.
//

import Foundation
import Combine

protocol PostNotificationReadUseCase {
    func execute(notificationId: Int) -> AnyPublisher<Void, ErrorResponse>
}

final class DefaultPostNotificationReadUseCase: PostNotificationReadUseCase {
    
    private let repository: CallVanRepository
    
    init(repository: CallVanRepository) {
        self.repository = repository
    }
    
    func execute(notificationId: Int) -> AnyPublisher<Void, ErrorResponse> {
        return repository.postNotificationRead(notificationId)
    }
}
