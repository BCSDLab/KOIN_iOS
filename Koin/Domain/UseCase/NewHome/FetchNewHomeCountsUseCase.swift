//
//  FetchNewHomeCountsUseCase.swift
//  koin
//
//  Created by 홍기정 on 6/2/26.
//

import Combine
import Foundation

protocol FetchNewHomeCountsUseCase {
    func execute() -> AnyPublisher<NewHomeCounts, Never>
}

final class MockFetchNewHomeCountsUseCase: FetchNewHomeCountsUseCase {
    func execute() -> AnyPublisher<NewHomeCounts, Never> {
        Just(
            NewHomeCounts(
                callVanRecruitingCount: 14,
                eventCount: 3,
                openShopCount: 24,
                totalShopCount: 72
            )
        )
        .eraseToAnyPublisher()
    }
}
