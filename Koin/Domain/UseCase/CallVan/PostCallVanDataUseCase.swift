//
//  PostCallVanDataUseCase.swift
//  koin
//
//  Created by 홍기정 on 3/10/26.
//

import UIKit
import Combine

protocol PostCallVanDataUseCase {
    func execute(request: CallVanPostRequest) -> AnyPublisher<CallVanListPost, ErrorResponse>
}


final class DefaultPostCallVanDataUseCase: PostCallVanDataUseCase {
    
    private let repository: CallVanRepository
    
    init(repository: CallVanRepository) {
        self.repository = repository
    }
    
    func execute(request: CallVanPostRequest) -> AnyPublisher<CallVanListPost, ErrorResponse> {
        return repository.postData(request: request)
    }
}
