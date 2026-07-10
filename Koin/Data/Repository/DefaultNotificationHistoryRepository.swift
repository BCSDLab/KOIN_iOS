//
//  DefaultNotificationHistoryRepository.swift
//  koin
//
//  Created by 홍기정 on 7/7/26.
//

import Foundation

final class DefaultNotificationHistoryRepository: NotificationHistoryRepository {
    
    private let service: NotificationHistoryService
    
    init(service: NotificationHistoryService) {
        self.service = service
    }
       
    func fetchAll() async throws -> [NotificationItem] {
        try await service.fetchAll()
            .compactMap {
                NotificationItem.init(from: $0)
            }
    }
    
    func deleteAll() async throws {
        try await service.deleteAll()
    }
    
    func delete(id: String) async throws {
        try await service.delete(messageId: id)
    }
    
    func markAsRead(id: String) async throws {
        try await service.markAsRead(messageId: id)
    }
    
    func markAllAsRead() async throws {
        try await service.markAllAsRead()
    }
}
