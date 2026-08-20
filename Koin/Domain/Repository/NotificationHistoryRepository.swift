//
//  NotificationHistoryRepository.swift
//  koin
//
//  Created by 홍기정 on 7/7/26.
//

import Combine

protocol NotificationHistoryRepository {
    func fetchAll() async throws -> [NotificationHistoryItem]
    func deleteAll() async throws
    func delete(id: String) async throws
    func markAsRead(id: String) async throws
    func markAllAsRead() async throws
}
