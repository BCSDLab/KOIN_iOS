//
//  CheckHasUnreadNotificationHistoryUseCase.swift
//  koin
//
//  Created by 홍기정 on 7/14/26.
//

import Foundation

protocol CheckHasUnreadNotificationHistoryUseCase {
    func execute() async throws -> Bool
}

final class DefaultCheckHasUnreadNotificationHistoryUseCase: CheckHasUnreadNotificationHistoryUseCase {
    
    private let repository: NotificationHistoryRepository
    
    init(repository: NotificationHistoryRepository) {
        self.repository = repository
    }
    
    func execute() async throws -> Bool {
        do {
            let unreads = try await repository.fetchAll().filter { !$0.isRead }
            return unreads.isEmpty ? false : true
        }
    }
}
