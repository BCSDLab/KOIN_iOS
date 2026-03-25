//
//  DeleteAllNotificationsUseCase.swift
//  koin
//
//  Created by 홍기정 on 3/15/26.
//

import Foundation
import Combine

protocol DeleteAllNotificationsUseCase {
    func execute() -> AnyPublisher<Void, ErrorResponse>
}

final class DefaultDeleteAllNotificationsUseCase: DeleteAllNotificationsUseCase {
    
    private let repository: CallVanRepository
    
    init(repository: CallVanRepository) {
        self.repository = repository
    }
    
    func execute() -> AnyPublisher<Void, ErrorResponse> {
        return repository.deleteAllNotifications()
    }
}
