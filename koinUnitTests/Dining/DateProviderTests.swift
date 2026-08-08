//
//  DateProviderTests.swift
//  koinUnitTests
//
//  Created by 이은지 on 8/8/26.
//

import Foundation
import Testing
@testable import koin

@Suite("DateProvider - 시간대 판단 로직 경계값")
struct DateProviderTests {

    private let sut = DefaultDateProvider()
    private let calendar = Calendar.current

    private func date(hour: Int, minute: Int) throws -> Date {
        try #require(DiningFixture.date(hour: hour, minute: minute, calendar: calendar))
    }

    @Test("09:00 이전이면 breakfast를 반환한다")
    func 아홉시_이전이면_breakfast를_반환한다() throws {
        let input = try date(hour: 8, minute: 59)

        let result = sut.execute(date: input)

        #expect(result.diningType == .breakfast)
        #expect(calendar.isDate(result.date, inSameDayAs: input))
    }

    @Test("09:00이면 lunch를 반환한다")
    func 아홉시면_lunch를_반환한다() throws {
        let input = try date(hour: 9, minute: 0)

        let result = sut.execute(date: input)

        #expect(result.diningType == .lunch)
        #expect(calendar.isDate(result.date, inSameDayAs: input))
    }

    @Test("13:30이면 lunch를 반환한다")
    func 열세시_삼십분이면_lunch를_반환한다() throws {
        let input = try date(hour: 13, minute: 30)

        let result = sut.execute(date: input)

        #expect(result.diningType == .lunch)
    }

    @Test("13:31이면 dinner를 반환한다")
    func 열세시_삼십일분이면_dinner를_반환한다() throws {
        let input = try date(hour: 13, minute: 31)

        let result = sut.execute(date: input)

        #expect(result.diningType == .dinner)
        #expect(calendar.isDate(result.date, inSameDayAs: input))
    }

    @Test("18:30이면 dinner를 반환한다")
    func 열여덟시_삼십분이면_dinner를_반환한다() throws {
        let input = try date(hour: 18, minute: 30)

        let result = sut.execute(date: input)

        #expect(result.diningType == .dinner)
    }

    @Test("18:30 이후면 다음 날 breakfast를 반환한다", arguments: [(18, 31), (23, 59)])
    func 열여덟시_삼십분_이후면_다음_날_breakfast를_반환한다(hour: Int, minute: Int) throws {
        let input = try date(hour: hour, minute: minute)
        let expectedNextDay = try #require(calendar.date(byAdding: .day, value: 1, to: input))

        let result = sut.execute(date: input)

        #expect(result.diningType == .breakfast)
        #expect(calendar.isDate(result.date, inSameDayAs: expectedNextDay))
    }
}
