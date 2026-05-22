//
//  DeleteDeviceTokenUseCase.swift
//  koin
//
//  Created by 홍기정 on 5/22/26.
//

import Foundation
import Combine

protocol DeleteDeviceTokenUseCase {
    func execute() -> AnyPublisher<Void, ErrorResponse>
}

final class DefaultDeleteDeviceTokenUseCase: DeleteDeviceTokenUseCase {
    
    private let repository: NotiRepository
    
    init(repository: NotiRepository) {
        self.repository = repository
    }
    
    func execute() -> AnyPublisher<Void, ErrorResponse> {
        repository.deleteDeviceToken()
    }
}
