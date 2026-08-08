//
//  SpyDiningRepository.swift
//  koinUnitTests
//
//  Created by 이은지 on 8/8/26.
//

import Combine
import Foundation
@testable import koin

/// 호출 여부와 전달된 인자를 기록만 하고, 검증은 테스트 코드에 맡기는 테스트 더블.
final class SpyDiningRepository: DiningRepository {

    /// `fetchDiningList`가 돌려줄 응답. 테스트에서 시나리오별로 갈아끼운다.
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
