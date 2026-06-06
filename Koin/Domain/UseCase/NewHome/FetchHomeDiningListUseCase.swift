//
//  FetchHomeDiningListUseCase.swift
//  koin
//
//  Created by 홍기정 on 6/3/26.
//

import Combine
import Foundation

protocol FetchHomeDiningListUseCase {
    func execute() -> AnyPublisher<[HomeDiningItem], ErrorResponse>
}

final class DefaultFetchHomeDiningListUseCase: FetchHomeDiningListUseCase {
    private let fetchDiningListUseCase: FetchDiningListUseCase
    private let dateProvider: DateProvider

    init(fetchDiningListUseCase: FetchDiningListUseCase, dateProvider: DateProvider) {
        self.fetchDiningListUseCase = fetchDiningListUseCase
        self.dateProvider = dateProvider
    }

    func execute() -> AnyPublisher<[HomeDiningItem], ErrorResponse> {
        let dateInfo = dateProvider.execute(date: Date())

        return fetchDiningListUseCase.execute(diningInfo: dateInfo)
            .map { diningItems in
                diningItems
                    .map(HomeDiningItem.init)
            }
            .eraseToAnyPublisher()
    }
}
