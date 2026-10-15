//
//  FetchDiningListUseCaseTests.swift
//  koinUnitTests
//
//  Created by 이은지 on 8/8/26.
//

import Foundation
import Testing
@testable import koin

#if false // TODO: 식단 리팩토링 후 테스트 재작성
@Suite("FetchDiningListUseCase - segmentControl에 따른 데이터 필터링")
struct FetchDiningListUseCaseTests {

    private func makeSUT(
        stubbedDiningList: [DiningItem]
    ) -> (sut: DefaultFetchDiningListUseCase, spy: SpyDiningRepository) {
        let spy = SpyDiningRepository()
        spy.stubbedDiningList = stubbedDiningList
        return (DefaultFetchDiningListUseCase(diningRepository: spy), spy)
    }

    private func diningInfo(
        type: DiningType,
        date: Date = Date()
    ) -> CurrentDiningTime {
        CurrentDiningTime(date: date, diningType: type)
    }

    @Test("요청한 시간대의 식단만 반환한다")
    func 요청한_시간대의_식단만_반환한다() async throws {
        let (sut, _) = makeSUT(stubbedDiningList: [
            DiningFixture.item(id: 1, type: .breakfast, place: .cornerA),
            DiningFixture.item(id: 2, type: .lunch, place: .cornerB),
            DiningFixture.item(id: 3, type: .dinner, place: .cornerC),
            DiningFixture.item(id: 4, type: .lunch, place: .special)
        ])

        let result = try await sut.execute(diningInfo: diningInfo(type: .lunch)).firstValue()

        #expect(result.count == 2)
        #expect(result.allSatisfy { $0.type == .lunch })
        #expect(result.map(\.id).sorted() == [2, 4])
    }

    @Test(
        "미운영 메뉴는 제외한다",
        arguments: [DiningType.breakfast, .lunch, .dinner]
    )
    func 미운영_메뉴는_제외한다(requestedType: DiningType) async throws {
        let (sut, _) = makeSUT(stubbedDiningList: [
            DiningFixture.item(id: 1, type: requestedType, place: .cornerA, menu: ["미운영"]),
            DiningFixture.item(id: 2, type: requestedType, place: .cornerB, menu: ["김치찌개", "밥"])
        ])

        let result = try await sut.execute(diningInfo: diningInfo(type: requestedType)).firstValue()

        #expect(result.count == 1)
        #expect(result.first?.id == 2)
        #expect(!result.contains { $0.menu.first == "미운영" })
    }

    @Test("장소 우선순위대로 정렬한다")
    func 장소_우선순위대로_정렬한다() async throws {
        let (sut, _) = makeSUT(stubbedDiningList: [
            DiningFixture.item(id: 1, type: .lunch, place: .secondCampus),
            DiningFixture.item(id: 2, type: .lunch, place: .special),
            DiningFixture.item(id: 3, type: .lunch, place: .cornerC),
            DiningFixture.item(id: 4, type: .lunch, place: .cornerA),
            DiningFixture.item(id: 5, type: .lunch, place: .cornerB)
        ])

        let result = try await sut.execute(diningInfo: diningInfo(type: .lunch)).firstValue()

        #expect(result.map(\.place) == [.cornerA, .cornerB, .cornerC, .special, .secondCampus])
    }

    @Test("요청 날짜를 그대로 전달한다")
    func 요청_날짜를_그대로_전달한다() async throws {
        let (sut, spy) = makeSUT(stubbedDiningList: [])
        let requestedDate = try #require(DiningFixture.date(year: 2026, month: 8, day: 3))

        _ = try await sut.execute(diningInfo: diningInfo(type: .lunch, date: requestedDate)).firstValue()

        #expect(spy.fetchDiningListCallCount == 1)
        #expect(spy.receivedFetchRequests.first == requestedDate)
    }
}
#endif
