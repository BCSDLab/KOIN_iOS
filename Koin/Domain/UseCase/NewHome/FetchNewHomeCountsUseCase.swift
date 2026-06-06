//
//  FetchNewHomeCountsUseCase.swift
//  koin
//
//  Created by 홍기정 on 6/2/26.
//

import Combine
import Foundation

protocol FetchNewHomeCountsUseCase {
    func execute() -> AnyPublisher<NewHomeCounts, ErrorResponse>
}

final class DefaultFetchNewHomeCountsUseCase: FetchNewHomeCountsUseCase {
    
    private let shopRepository: ShopRepository
    private let callvanRepository: CallVanRepository
    
    init(shopRepository: ShopRepository, callvanRepository: CallVanRepository) {
        self.shopRepository = shopRepository
        self.callvanRepository = callvanRepository
    }
    
    func execute() -> AnyPublisher<NewHomeCounts, ErrorResponse> {
        callvanRepository.fetchCallVanList(request: .init(state: .recruiting, limit: 0))
            .zip(shopRepository.fetchEventCount(), shopRepository.fetchShopCount())
            .map { (callVanList, eventShopCount, shopCount) in
                NewHomeCounts(
                    callVanRecruitingCount: callVanList.totalCount,
                    eventCount: eventShopCount,
                    openShopCount: shopCount.openCount,
                    totalShopCount: shopCount.totalCount)
            }
            .eraseToAnyPublisher()
    }
}
