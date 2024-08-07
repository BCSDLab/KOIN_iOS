//
//  SendDeviceTokenUseCase.swift
//  koin
//
//  Created by 김나훈 on 7/30/24.
//

import Combine

protocol SendDeviceTokenUseCase {
    func execute() -> AnyPublisher<Void, ErrorResponse>
}

final class DefaultSendDeviceTokenUseCase: SendDeviceTokenUseCase {
    
    private let notiRepository: NotiRepository
    
    init(notiRepository: NotiRepository) {
        self.notiRepository = notiRepository
    }
    
    func execute() -> AnyPublisher<Void, ErrorResponse> {
        return notiRepository.sendDeviceToken()
    }
    
}
