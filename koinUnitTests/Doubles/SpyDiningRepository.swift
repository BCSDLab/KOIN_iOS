//
//  SpyDiningRepository.swift
//  koinUnitTests
//
//  Created by 이은지 on 8/8/26.
//

import Combine
import Foundation
@testable import koin

final class SpyDiningRepository: DiningRepository {

    var stubbedDiningList: [DiningItem] = []
    var stubbedCoopShopData = CoopShopData(
        location: "", phone: "", remarks: "", name: "", semester: "", opens: [], updatedAt: ""
    )

    private(set) var fetchDiningListCallCount = 0
    private(set) var receivedFetchRequests: [Date] = []
    private(set) var receivedShareModels: [ShareDiningMenu] = []

    func fetchDiningList(date: Date) -> AnyPublisher<[DiningItem], ErrorResponse> {
        fetchDiningListCallCount += 1
        receivedFetchRequests.append(date)
        return Just(stubbedDiningList)
            .setFailureType(to: ErrorResponse.self)
            .eraseToAnyPublisher()
    }

    func fetchCoopShopList() -> AnyPublisher<CoopShopData, ErrorResponse> {
        Just(stubbedCoopShopData)
            .setFailureType(to: ErrorResponse.self)
            .eraseToAnyPublisher()
    }

    func shareMenuList(shareModel: ShareDiningMenu) {
        receivedShareModels.append(shareModel)
    }
}
