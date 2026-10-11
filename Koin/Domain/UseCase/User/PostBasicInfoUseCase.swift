//
//  ModifyBasicInfoUseCase.swift
//  koin
//
//  Created by 홍기정 on 9/21/26.
//

import Foundation

protocol ModifyBasicInfoUseCase {
    func execute(basicInfo: BasicInfo) async throws
}

final class DefaultModifyBasicInfoUseCase: ModifyBasicInfoUseCase {
    private let repository: UserRepository

    init(repository: UserRepository) {
        self.repository = repository
    }

    func execute(basicInfo: BasicInfo) async throws {
        try await repository.modifyBasicInfo(basicInfo)
    }
}
