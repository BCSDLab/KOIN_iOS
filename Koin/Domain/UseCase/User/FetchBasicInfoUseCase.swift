//
//  FetchBasicInfoUseCase.swift
//  koin
//
//  Created by 홍기정 on 9/21/26.
//

import Foundation

protocol FetchBasicInfoUseCase {
    func execute() async throws -> BasicInfo
}

final class DefaultFetchBasicInfoUseCase: FetchBasicInfoUseCase {
    private let repository: UserRepository

    init(repository: UserRepository) {
        self.repository = repository
    }

    func execute() async throws -> BasicInfo {
        try await repository.fetchBasicInfo()
    }
}
