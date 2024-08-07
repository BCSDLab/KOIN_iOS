//
//  FetchNotiListUseCase.swift
//  koin
//
//  Created by 김나훈 on 7/27/24.
//

import Combine

protocol FetchNotiListUseCase {
    func execute() -> AnyPublisher<NotiAgreementDTO, ErrorResponse>
}

final class DefaultFetchNotiListUseCase: FetchNotiListUseCase {
    
    private let notiRepository: NotiRepository
    
    init(notiRepository: NotiRepository) {
        self.notiRepository = notiRepository
    }
    
    func execute() -> AnyPublisher<NotiAgreementDTO, ErrorResponse> {
        return notiRepository.fetchNotiList()
    }
    
}
