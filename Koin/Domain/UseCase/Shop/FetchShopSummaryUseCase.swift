//
//  FetchShopSummaryUseCase.swift
//  koin
//
//  Created by 홍기정 on 9/14/25.
//

import Combine

protocol FetchShopSummaryUseCase {
    func execute(shopId: Int) -> AnyPublisher<ShopSummary, ErrorResponse>
}

final class DefaultFetchShopSummaryUseCase: FetchShopSummaryUseCase {
    
    private let shopRepository: ShopRepository
    
    init(shopRepository: ShopRepository) {
        self.shopRepository = shopRepository
    }
    
    func execute(shopId: Int) -> AnyPublisher<ShopSummary, ErrorResponse> {
        let request = FetchShopDataRequest(shopId: shopId)
        return Publishers.Zip4(
            shopRepository.fetchShopSummary(id: shopId),
            shopRepository.fetchShopData(requestModel: request),
            shopRepository.fetchShopMenuList(requestModel: request),
            shopRepository.fetchShopEventList(requestModel: request)
        )
        .map { summaryDto, shopDataDto, menuDto, eventsDto in
            ShopSummary(
                summaryDto: summaryDto,
                shopData: shopDataDto.toDomain(),
                menuDto: menuDto,
                eventsDto: eventsDto
            )
        }
        .eraseToAnyPublisher()
    }
}
