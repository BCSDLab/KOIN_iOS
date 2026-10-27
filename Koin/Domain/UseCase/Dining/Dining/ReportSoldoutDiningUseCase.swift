//
//  ReportSoldoutDiningUseCase.swift
//  koin
//
//  Created by 홍기정 on 10/18/26.
//

import Foundation

protocol ReportSoldoutDiningUseCase {
    func execute(diningId: Int, imageUrl: String) async throws -> Void
}

final class DefaultReportSoldoutDiningUseCase: ReportSoldoutDiningUseCase {
    
    private let repository: DiningRepository
    
    init(repository: DiningRepository) {
        self.repository = repository
    }
    
    func execute(diningId: Int, imageUrl: String) async throws -> Void {
        try await repository.reportSoldout(diningId: diningId, imageUrl: imageUrl)
    }
}
