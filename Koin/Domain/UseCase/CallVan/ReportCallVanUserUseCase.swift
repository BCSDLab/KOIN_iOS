//
//  ReportCallVanUserUseCase.swift
//  koin
//
//  Created by 홍기정 on 3/16/26.
//

import Foundation
import Combine

protocol ReportCallVanUserUseCase {
    func execute(postId: Int, request: CallVanReportRequest) -> AnyPublisher<Void, ErrorResponse>
}

final class DefaultReportCallVanUserUseCase: ReportCallVanUserUseCase {
    
    private let repository: CallVanRepository
    
    init(repository: CallVanRepository) {
        self.repository = repository
    }
    
    func execute(postId: Int, request: CallVanReportRequest) -> AnyPublisher<Void, ErrorResponse> {
        return repository.report(postId: postId, request: request)
    }
}
