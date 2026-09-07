//
//  RecruitRepository.swift
//  koin
//
//  Created by 홍기정 on 8/29/26.
//

import Foundation

protocol RecruitRepository {
    func fetchList(_ filter: RecruitListFilter) async throws -> RecruitList
    func fetchNotificationList() async throws -> RecruitNotificationList
    func deleteNotification(_ id: Int) async throws -> Void
    func deleteAllNotification() async throws -> Void
    func markAsReadNotification(_ id: Int) async throws -> Void
    func markAllAsReadNotification() async throws -> Void
}
