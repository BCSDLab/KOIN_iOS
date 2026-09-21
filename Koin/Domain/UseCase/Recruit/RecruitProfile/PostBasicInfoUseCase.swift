//
//  PostBasicInfoUseCase.swift
//  koin
//
//  Created by 홍기정 on 9/21/26.
//

import Foundation

protocol PostBasicInfoUseCase {
    func execute(basicInfo: BasicInfo) async throws -> BasicInfo
}

final class DefaultPostBasicInfoUseCase: PostBasicInfoUseCase {
    private let repository: RecruitRepository

    init(repository: RecruitRepository) {
        self.repository = repository
    }

    func execute(basicInfo: BasicInfo) async throws -> BasicInfo {
        try await repository.postBasicInfo(basicInfo)
    }
}
