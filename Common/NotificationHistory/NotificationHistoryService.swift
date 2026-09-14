//
//  NotificationContainer.swift
//  koin
//
//  Created by 홍기정 on 7/6/26.
//

import SwiftData
import Foundation

protocol NotificationHistoryService {
    func insert(record: NotificationHistoryRecord) async throws
    func fetchAll() async throws -> [NotificationHistoryRecord]
    func markAsRead(messageId: String) async throws
    func markAllAsRead() async throws
    func delete(messageId: String) async throws
    func deleteAll() async throws
}

final class DefaultNotificationHistoryService: NotificationHistoryService {
    
    // MARK: - Properties
    private let container: ModelContainer?
    
    // MARK: - Initializer
    init() {
        container = try? ModelContainer(
            for: NotificationHistoryRecord.self,
            configurations: .init(groupContainer: .identifier("group.com.bcsdlab.koin"))
        )
    }
    
    // MARK: - Create
    func insert(record: NotificationHistoryRecord) async throws {
        guard let container else {
            throw SwiftDataError.loadIssueModelContainer
        }
        
        switch record.category {
        case .shop, .dining, .keyword, .chat, .callvan, .callvanChat:
            try await MainActor.run { [weak container] in
                container?.mainContext.insert(record)
                try container?.mainContext.save()
            }
        default:
            break
        }
    }
    
    // MARK: - Read
    func fetchAll() async throws -> [NotificationHistoryRecord] {
        guard let container else {
            throw SwiftDataError.loadIssueModelContainer
        }
        
        do {
            try await deleteExpiredNotifications()
        } catch {
            print(error.localizedDescription)
        }
        
        return try await MainActor.run {
            var descriptor = FetchDescriptor<NotificationHistoryRecord>(
                sortBy: [SortDescriptor(\.createdAt, order: .reverse)]
            )
            descriptor.fetchLimit = .max
            
            return try container.mainContext.fetch(descriptor)
        }
    }
    
    // MARK: - Update
    func markAsRead(messageId: String) async throws {
        guard let container else {
            throw SwiftDataError.loadIssueModelContainer
        }
        
        try await MainActor.run {
            var descriptor = FetchDescriptor<NotificationHistoryRecord>(
                predicate: #Predicate { notification in
                    notification.messageId == messageId
                }
            )
            descriptor.fetchLimit = 1
            if let notification = try container.mainContext.fetch(descriptor).first {
                notification.isRead = true
            }
            try container.mainContext.save()
        }
        
        postNotificationRead()
    }
    
    func markAllAsRead() async throws {
        guard let container else {
            throw SwiftDataError.loadIssueModelContainer
        }
        
        try await MainActor.run {
            var descriptor = FetchDescriptor<NotificationHistoryRecord>()
            descriptor.fetchLimit = .max
            try container.mainContext.enumerate(descriptor) { notification in
                notification.isRead = true
            }
            try container.mainContext.save()
        }
        
        postNotificationRead()
    }
    
    // MARK: - Delete
    func delete(messageId: String) async throws {
        guard let container else {
            throw SwiftDataError.loadIssueModelContainer
        }
        
        try await MainActor.run {
            try container.mainContext.delete(model: NotificationHistoryRecord.self, where: #Predicate { notification in
                notification.messageId == messageId
            })
            try container.mainContext.save()
        }
        
        postNotificationRead()
    }
    
    func deleteAll() async throws {
        guard let container else {
            throw SwiftDataError.loadIssueModelContainer
        }
        
        try await MainActor.run {
            try container.mainContext.delete(model: NotificationHistoryRecord.self)
            try container.mainContext.save()
        }
        
        postNotificationRead()
    }
}

extension DefaultNotificationHistoryService {
    private func deleteExpiredNotifications() async throws {
        guard let container else {
            throw SwiftDataError.loadIssueModelContainer
        }
        
        guard let expirationDate = Calendar.current.date(byAdding: .day, value: -14, to: Date()) else {
            throw NotificationHistoryError.calendarDidFail
        }
        
        try await MainActor.run {
            try container.mainContext.delete(model: NotificationHistoryRecord.self, where: #Predicate { notification in
                notification.createdAt < expirationDate
            })
            try container.mainContext.save()
        }
    }
}

extension DefaultNotificationHistoryService {
    private func postNotificationRead() {
        NotificationCenter.default.post(
            name: NSNotification.Name("Notification Read"),
            object: nil
        )
    }
}
