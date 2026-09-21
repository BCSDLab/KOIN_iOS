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
    func post(_ request: RecruitPostRequest) async throws -> Int
    func modify(_ id: Int, _ request: RecruitPostRequest) async throws -> Void
    func fetchData(_ id: Int) async throws -> RecruitData
    func deleteData(id: Int) async throws -> Bool
    func fetchMyProfile() async throws -> RecruitProfile
    func postBasicInfo(_ basicInfo: BasicInfo) async throws -> BasicInfo
    func postRecruitProfile(_ request: RecruitProfileRequest) async throws -> RecruitProfile
}
