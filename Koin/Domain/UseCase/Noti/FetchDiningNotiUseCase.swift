//
//  FetchDiningNotiUseCase.swift
//  koin
//
//  Created by 홍기정 on 10/19/26.
//

import Foundation

protocol FetchDiningNotiUseCase {
    func execute() async throws -> DiningNoti
}

final class DefaultFetchDiningNotiUseCase: FetchDiningNotiUseCase {
    
    private let notiRepository: NotiRepository
    
    init(notiRepository: NotiRepository) {
        self.notiRepository = notiRepository
    }
    
    func execute() async throws -> DiningNoti {
        let subscribes = try await notiRepository.fetchNotiList().firstValue().subscribes
        guard let isDiningSoldOutPermit = subscribes?.first(where: { $0.type == .diningSoldOut })?.isPermit,
              let isDiningImageUploadPermit = subscribes?.first(where: { $0.type == .diningImageUpload })?.isPermit else {
            throw ErrorResponse.typeCastingError
        }
        return DiningNoti(
            isDiningSoldOutPermit: isDiningSoldOutPermit,
            isDiningImageUploadPermit: isDiningImageUploadPermit
        )
    }
}



