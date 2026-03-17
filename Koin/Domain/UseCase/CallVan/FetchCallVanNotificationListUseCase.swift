//
//  FetchCallVanNotificationListUseCase.swift
//  koin
//
//  Created by 홍기정 on 3/5/26.
//

import Foundation
import Combine

protocol FetchCallVanNotificationListUseCase {
    func execute() -> AnyPublisher<[CallVanNotification], ErrorResponse>
}

import Combine
import Foundation

final class DefaultFetchCallVanNotificationListUseCase: FetchCallVanNotificationListUseCase {
    
    private let repository: CallVanRepository
    
    init(repository: CallVanRepository) {
        self.repository = repository
    }
    
    func execute() -> AnyPublisher<[CallVanNotification], ErrorResponse> {
        return repository.fetchNotification()
    }
}
