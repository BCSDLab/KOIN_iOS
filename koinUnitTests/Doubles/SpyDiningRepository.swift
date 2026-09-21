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

    var stubbedDiningList: [DiningDto] = []

    private(set) var fetchDiningListCallCount = 0
    private(set) var receivedFetchRequests: [FetchDiningListRequest] = []
    private(set) var receivedShareModels: [ShareDiningMenu] = []

    func fetchDiningList(requestModel: FetchDiningListRequest) -> AnyPublisher<[DiningDto], ErrorResponse> {
        fetchDiningListCallCount += 1
        receivedFetchRequests.append(requestModel)
        return Just(stubbedDiningList)
            .setFailureType(to: ErrorResponse.self)
            .eraseToAnyPublisher()
    }

    func fetchCoopShopList() -> AnyPublisher<CoopShopDto, ErrorResponse> {
        Empty<CoopShopDto, ErrorResponse>().eraseToAnyPublisher()
    }

    func shareMenuList(shareModel: ShareDiningMenu) {
        receivedShareModels.append(shareModel)
    }
}
