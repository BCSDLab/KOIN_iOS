//
//  FetchHomeDiningListUseCase.swift
//  koin
//
//  Created by 홍기정 on 6/3/26.
//

import Combine
import Foundation

protocol FetchHomeDiningListUseCase {
    func execute() -> AnyPublisher<[HomeDiningItem], Never>
}

final class DefaultFetchHomeDiningListUseCase: FetchHomeDiningListUseCase {
    private let fetchDiningListUseCase: FetchDiningListUseCase
    private let dateProvider: DateProvider

    init(fetchDiningListUseCase: FetchDiningListUseCase, dateProvider: DateProvider) {
        self.fetchDiningListUseCase = fetchDiningListUseCase
        self.dateProvider = dateProvider
    }

    func execute() -> AnyPublisher<[HomeDiningItem], Never> {
        let dateInfo = dateProvider.execute(date: Date())

        return fetchDiningListUseCase.execute(diningInfo: dateInfo)
            .replaceError(with: [])
            .map { diningItems in
                diningItems
                    .sortedForNewHome()
                    .map(HomeDiningItem.init)
            }
            .eraseToAnyPublisher()
    }
}

private extension HomeDiningItem {
    init(_ diningItem: DiningItem) {
        self.init(
            id: diningItem.id,
            placeName: diningItem.place.rawValue,
            timeText: diningItem.type.newHomeDiningTimeText,
            priceText: diningItem.newHomeDiningPriceText,
            kcalText: "\(diningItem.kcal)kcal",
            menu: diningItem.menu
        )
    }
}

private extension DiningItem {
    var newHomeDiningPriceText: String? {
        guard let price = priceCash ?? priceCard, price > 0 else { return nil }
        return "₩\(price.formatted(.number))"
    }
}

private extension DiningType {
    var newHomeDiningTimeText: String {
        switch self {
        case .breakfast:
            return "08:30 – 09:30"
        case .lunch:
            return "11:30 – 13:30"
        case .dinner:
            return "17:30 – 18:30"
        }
    }
}

private extension Array where Element == DiningItem {
    func sortedForNewHome() -> [DiningItem] {
        sorted { lhs, rhs in
            lhs.place.newHomeDiningSortOrder < rhs.place.newHomeDiningSortOrder
        }
    }
}

private extension DiningPlace {
    var newHomeDiningSortOrder: Int {
        switch self {
        case .cornerA:
            return 0
        case .cornerB:
            return 1
        case .cornerC:
            return 2
        case .special:
            return 3
        case .secondCampus:
            return 4
        }
    }
}
