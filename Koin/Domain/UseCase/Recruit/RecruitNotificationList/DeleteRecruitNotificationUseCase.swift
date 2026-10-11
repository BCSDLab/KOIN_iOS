//
//  DeleteRecruitNotificationUseCase.swift
//  koin
//
//  Created by 홍기정 on 8/29/26.
//

import Foundation

protocol DeleteRecruitNotificationUseCase {
    func execute(id: Int?) async throws -> Void
}

final class DefaultDeleteRecruitNotificationUseCase: DeleteRecruitNotificationUseCase {

    private let repository: RecruitRepository
    
    init(repository: RecruitRepository) {
        self.repository = repository
    }
    
    func execute(id: Int? = nil) async throws -> Void {
        if let id {
            try await repository.deleteNotification(id)
        } else {
            try await repository.deleteAllNotification()
        }
    }
}
