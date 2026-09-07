//
//  MarkAsReadRecruitNotificationUseCase.swift
//  koin
//
//  Created by 홍기정 on 8/29/26.
//

import Foundation

protocol MarkAsReadRecruitNotificationUseCase {
    func execute(id: Int?) async throws -> Void
}

final class DefaultMarkAsReadRecruitNotificationUseCase: MarkAsReadRecruitNotificationUseCase {

    private let repository: RecruitRepository
    
    init(repository: RecruitRepository) {
        self.repository = repository
    }
    
    func execute(id: Int?) async throws -> Void {
        if let id {
            try await repository.markAsReadNotification(id)
        } else {
            try await repository.markAllAsReadNotification()
        }
    }
}
