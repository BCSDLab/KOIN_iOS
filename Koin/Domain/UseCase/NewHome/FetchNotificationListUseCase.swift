//
//  FetchHomeDiningListUseCase.swift
//  koin
//
//  Created by 홍기정 on 6/3/26.
//

import Combine
import Foundation

protocol FetchNotificationHistoryUseCase {
    func execute() async throws -> [NotificationItem]
}

final class DefaultFetchNotificationHistoryUseCase: FetchNotificationHistoryUseCase {
    
    private let notificationHistoryRepository: NotificationHistoryRepository
    
    init(notificationHistoryRepository: NotificationHistoryRepository) {
        self.notificationHistoryRepository = notificationHistoryRepository
    }
    
    func execute() async throws -> [NotificationItem] {
        try await notificationHistoryRepository.fetchAll()
    }
}
