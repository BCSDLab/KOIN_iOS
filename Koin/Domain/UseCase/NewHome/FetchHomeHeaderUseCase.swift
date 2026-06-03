//
//  FetchHomeHeaderUseCase.swift
//  koin
//
//  Created by 홍기정 on 6/3/26.
//

import Combine
import Foundation

protocol FetchHomeHeaderUseCase {
    func execute() -> AnyPublisher<HomeHeader, Never>
}

final class MockFetchHomeHeaderUseCase: FetchHomeHeaderUseCase {
    func execute() -> AnyPublisher<HomeHeader, Never> {
        Just(
            HomeHeader(
                dateText: Self.dateText(from: Date()),
                weatherText: "맑음 18°",
                weatherImage: .weatherSunny,
                userName: "익명",
                message: "오늘도 잘 챙겨먹어요"
            )
        )
        .eraseToAnyPublisher()
    }
}

private extension MockFetchHomeHeaderUseCase {
    static func dateText(from date: Date) -> String {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "ko_KR")
        formatter.dateFormat = "M월 d일 EEEE"
        return formatter.string(from: date)
    }
}
