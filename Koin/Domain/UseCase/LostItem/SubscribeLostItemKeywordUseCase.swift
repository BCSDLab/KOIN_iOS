//
//  SubscribeLostItemKeywordUseCase.swift
//  koin
//
//  Created by 홍기정 on 5/12/26.
//

import Foundation
import Combine

protocol SubscribeLostItemKeywordUseCase {
    func execute(keyword: String) -> AnyPublisher<LostItemKeyword, ErrorResponse>
}

final class DefaultSubscribeLostItemKeywordUseCase: SubscribeLostItemKeywordUseCase {
    
    private let repository: LostItemRepository
    
    init(repository: LostItemRepository) {
        self.repository = repository
    }
    
    func execute(keyword: String) -> AnyPublisher<LostItemKeyword, ErrorResponse> {
        let requestModel = SubscribeKeywordRequest(keyword: keyword)
        return repository.subscribeKeyword(requestModel: requestModel)
    }
}
