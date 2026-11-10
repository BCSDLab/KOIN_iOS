//
//  FetchHomeDiningListUseCase.swift
//  koin
//
//  Created by 홍기정 on 6/3/26.
//

import Combine
import Foundation

protocol FetchHomeDiningListUseCase {
    func execute() -> AnyPublisher<HomeDiningResult, ErrorResponse>
}

final class DefaultFetchHomeDiningListUseCase: FetchHomeDiningListUseCase {
    private let fetchDiningListUseCase: FetchDiningListUseCase
    private let fetchCoopShopListUseCase: FetchCoopShopListUseCase
    private let dateProvider: DateProvider

    init(
        fetchDiningListUseCase: FetchDiningListUseCase,
        fetchCoopShopListUseCase: FetchCoopShopListUseCase,
        dateProvider: DateProvider
    ) {
        self.fetchDiningListUseCase = fetchDiningListUseCase
        self.fetchCoopShopListUseCase = fetchCoopShopListUseCase
        self.dateProvider = dateProvider
    }

    func execute() -> AnyPublisher<HomeDiningResult, ErrorResponse> {
        let dateInfo = dateProvider.execute(date: Date())
        
        return fetchDiningListUseCase.execute(diningInfo: dateInfo)
            .zip(fetchCoopShopListUseCase.execute())
            .map { (diningItems, coopShopData) in
                let weekdayOperatingTimes = self.weekdayOperatingTimes(from: coopShopData)

                let items = diningItems
                    .filter { $0.place != .secondCampus }
                    .map {
                        HomeDiningItem(
                            $0,
                            timeText: weekdayOperatingTimes[$0.type]
                        )
                    }
                return HomeDiningResult(diningType: dateInfo.diningType, items: items)
            }
            .eraseToAnyPublisher()
    }
}

extension DefaultFetchHomeDiningListUseCase {
    private func weekdayOperatingTimes(from coopShopData: CoopShopData) -> [DiningType: String] {
        coopShopData.opens
            .filter { $0.dayOfWeek == .weekday }
            .reduce(into: [:]) { result, open in
                guard let diningType = DiningType(mealType: open.type) else { return }
                
                if open.openTime != "미운영",
                   open.closeTime != "미운영",
                   !open.openTime.isEmpty,
                   !open.closeTime.isEmpty {
                    result[diningType] = "\(open.openTime) - \(open.closeTime)"
                } else {
                    result[diningType] = nil
                }
            }
    }
}

private extension DiningType {
    init?(mealType: MealType) {
        switch mealType {
        case .breakfast:
            self = .breakfast
        case .lunch:
            self = .lunch
        case .dinner:
            self = .dinner
        }
    }
}
