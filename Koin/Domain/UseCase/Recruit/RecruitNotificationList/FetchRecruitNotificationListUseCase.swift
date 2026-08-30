//
//  FetchRecruitNotificationListUseCase.swift
//  koin
//
//  Created by 홍기정 on 8/29/26.
//

import Foundation

protocol FetchRecruitNotificationListUseCase {
    func execute() async throws -> RecruitNotificationList
}

final class DefaultFetchRecruitNotificationListUseCase: FetchRecruitNotificationListUseCase {

    private let repository: RecruitRepository
    
    init(repository: RecruitRepository) {
        self.repository = repository
    }
    
    func execute() async throws -> RecruitNotificationList {
        try await repository.fetchNotificationList()
    }
}
