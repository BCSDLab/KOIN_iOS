//
//  UpdateNotificationHistoryUseCase.swift
//  koin
//
//  Created by 홍기정 on 7/7/26.
//

import Foundation

protocol UpdateNotificationHistoryUseCase {
    func markAsRead(id: String) async throws
    func markAllAsRead() async throws
}

final class DefaultUpdateNotificationHistoryUseCase: UpdateNotificationHistoryUseCase {
    
    private let repository: NotificationHistoryRepository
    
    init(repository: NotificationHistoryRepository) {
        self.repository = repository
    }
    
    func markAsRead(id: String) async throws {
        try await repository.markAsRead(id: id)
    }
    
    func markAllAsRead() async throws {
        try await repository.markAllAsRead()
    }
}
