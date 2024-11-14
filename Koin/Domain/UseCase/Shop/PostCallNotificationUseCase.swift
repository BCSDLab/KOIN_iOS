//
//  PostCallNotificationUseCase.swift
//  koin
//
//  Created by 김나훈 on 11/14/24.
//


import Combine

protocol PostCallNotificationUseCase {
    func execute(shopId: Int) -> AnyPublisher<Void, ErrorResponse>
}

final class DefaultPostCallNotificationUseCase: PostCallNotificationUseCase {

    private let shopRepository: ShopRepository
    
    init(shopRepository: ShopRepository) {
        self.shopRepository = shopRepository
    }

    func execute(shopId: Int) -> AnyPublisher<Void, ErrorResponse> {
        return shopRepository.postCallNotification(shopId: shopId)
    }
}
