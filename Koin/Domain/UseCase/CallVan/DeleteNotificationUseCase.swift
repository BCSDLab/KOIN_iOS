//
//  DeleteNotificationUseCase.swift
//  koin
//
//  Created by 홍기정 on 3/15/26.
//

import Foundation
import Combine

protocol DeleteNotificationUseCase {
    func execute(notificationId: Int) -> AnyPublisher<Void, ErrorResponse>
}

final class DefaultDeleteNotificationUseCase: DeleteNotificationUseCase {
    
    private let repository: CallVanRepository
    
    init(repository: CallVanRepository) {
        self.repository = repository
    }
    
    func execute(notificationId: Int) -> AnyPublisher<Void, ErrorResponse> {
        return repository.deleteNotification(notificationId: notificationId)
    }
}
