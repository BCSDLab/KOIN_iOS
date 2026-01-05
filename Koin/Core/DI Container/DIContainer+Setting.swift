//
//  DIContainer+Setting.swift
//  koin
//
//  Created by 홍기정 on 12/17/25.
//

import Foundation

        let checkDuplicatedNicknameUseCase = DefaultCheckDuplicatedNicknameUseCase(userRepository: DefaultUserRepository(service: DefaultUserService()))