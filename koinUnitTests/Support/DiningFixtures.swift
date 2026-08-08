//
//  DiningFixture.swift
//  koinUnitTests
//
//  Created by 이은지 on 8/8/26.
//

import Foundation
@testable import koin

enum DiningFixture {

    static func dto(
        id: Int = 1,
        date: String = "2026-08-03",
        type: DiningType = .lunch,
        place: DiningPlace = .cornerA,
        menu: [String]? = ["김치찌개", "밥"],
        imageURL: String? = nil
    ) -> DiningDto {
        DiningDto(
            id: id,
            date: date,
            type: type,
            place: place,
            priceCard: nil,
            priceCash: nil,
            kcal: nil,
            menu: menu,
            createdAt: "",
            updatedAt: "",
            soldoutAt: nil,
            changedAt: nil,
            imageURL: imageURL,
            likes: 0,
            isLiked: false
        )
    }

    static func item(
        id: Int = 1,
        date: String = "2026-08-03",
        type: DiningType = .lunch,
        place: DiningPlace = .cornerA,
        menu: [String] = ["김치찌개", "밥"],
        imageUrl: String? = nil
    ) -> DiningItem {
        DiningItem(
            id: id,
            type: type,
            place: place,
            priceCard: nil,
            priceCash: nil,
            kcal: 0,
            menu: menu,
            soldoutAt: nil,
            changedAt: nil,
            imageUrl: imageUrl,
            likes: 0,
            isLiked: false,
            date: date
        )
    }

    /// 프로덕션 코드(`DefaultDateProvider`, `Date.formatDateToYYMMDD()`)가 `Calendar.current`와
    /// 기본 `DateFormatter`를 쓰기 때문에, 테스트도 같은 기준으로 Date를 만든다.
    static func date(
        year: Int = 2026,
        month: Int = 8,
        day: Int = 3,
        hour: Int = 0,
        minute: Int = 0,
        calendar: Calendar = .current
    ) -> Date? {
        var components = DateComponents()
        components.year = year
        components.month = month
        components.day = day
        components.hour = hour
        components.minute = minute
        return calendar.date(from: components)
    }
}
