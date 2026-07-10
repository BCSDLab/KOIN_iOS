//
//  DeleteNotificationHistoryUseCase.swift
//  koin
//
//  Created by 홍기정 on 7/7/26.
//

import Foundation

protocol DeleteNotificationHistoryUseCase {
    func delete(id: String) async throws
    func deleteAll() async throws
}

final class DefaultDeleteNotificationHistoryUseCase: DeleteNotificationHistoryUseCase {
    
    private let repository: NotificationHistoryRepository
    
    init(repository: NotificationHistoryRepository) {
        self.repository = repository
    }
    
    func delete(id: String) async throws {
        try await repository.delete(id: id)
    }
    
    func deleteAll() async throws {
        try await repository.deleteAll()
    }
}
