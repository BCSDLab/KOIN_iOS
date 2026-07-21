//
//  SendDeviceTokenIfNeededUseCase.swift
//  koin
//
//  Created by 홍기정 on 5/21/26.
//

import Foundation
import Combine

protocol SendDeviceTokenIfNeededUseCase {
    func execute()
}

final class DefaultSendDeviceTokenIfNeededUseCase: SendDeviceTokenIfNeededUseCase {
    
    private let userRepository: UserRepository
    private let notiRepository: NotiRepository
    
    init (
        userRepository: UserRepository,
        notiRepository: NotiRepository
    ) {
        self.userRepository = userRepository
        self.notiRepository = notiRepository
    }
    
    func execute() {
        Task { [weak self] in
            guard let self,
                  await self.checkLogin() else {
                return
            }
            await self.sendDeviceToken()
        }
    }
}

extension DefaultSendDeviceTokenIfNeededUseCase {
    
    private func checkLogin() async -> Bool {
        await userRepository.checkLogin()
            .values
            .first { _ in true } ?? false
    }
    
    private func sendDeviceToken() async {
        await notiRepository.sendDeviceToken()
            .replaceError(with: ())
            .values
            .first { _ in true }
    }
}
