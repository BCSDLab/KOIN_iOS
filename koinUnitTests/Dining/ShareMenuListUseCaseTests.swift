//
//  ShareMenuListUseCaseTests.swift
//  koinUnitTests
//
//  Created by 이은지 on 8/8/26.
//

import Foundation
import Testing
@testable import koin

@Suite("ShareMenuListUseCase - 카카오톡 식단 공유하기")
struct ShareMenuListUseCaseTests {

    @Test("DiningItem을 ShareDiningMenu로 변환하면 메뉴와 이미지를 유지한다")
    func DiningItem을_ShareDiningMenu로_변환하면_메뉴와_이미지를_유지한다() {
        let item = DiningFixture.item(
            type: .lunch,
            place: .cornerA,
            menu: ["김치찌개", "밥"],
            imageUrl: "url1"
        )

        let shareModel = item.toShareDiningItem()

        #expect(shareModel.menuList == ["김치찌개", "밥"])
        #expect(shareModel.imageUrl == "url1")
        #expect(shareModel.type == .lunch)
        #expect(shareModel.place == .cornerA)
    }

    @Test("날짜를 yyMMdd 형식으로 변환한다")
    func 날짜를_yyMMdd_형식으로_변환한다() {
        let item = DiningFixture.item(date: "2026-08-03")

        let shareModel = item.toShareDiningItem()

        #expect(shareModel.date == "260803")
    }

    /// `DateFormatter`는 구분자가 달라도 관대하게 파싱하기 때문에 "2026/08/03"은 fallback 경로를 타지 않는다.
    /// (실제로 "260803"으로 변환된다.) 그래서 파싱이 확실히 실패하는 입력만 검증한다.
    @Test(
        "날짜 변환에 실패하면 원본 문자열을 사용한다",
        arguments: ["", "날짜없음", "2026-13-45"]
    )
    func 날짜_변환에_실패하면_원본_문자열을_사용한다(invalidDate: String) {
        let item = DiningFixture.item(date: invalidDate)

        let shareModel = item.toShareDiningItem()

        #expect(shareModel.date == invalidDate)
    }

    @Test("구분자가 달라도 파싱에 성공하면 yyMMdd로 변환된다")
    func 구분자가_달라도_파싱에_성공하면_yyMMdd로_변환된다() {
        let item = DiningFixture.item(date: "2026/08/03")

        let shareModel = item.toShareDiningItem()

        #expect(shareModel.date == "260803")
    }

    @Test("공유 모델을 레포지토리에 전달한다")
    func 공유_모델을_레포지토리에_전달한다() throws {
        let spy = SpyDiningRepository()
        let sut = DefaultShareMenuListUseCase(diningRepository: spy)
        let shareModel = DiningFixture.item(
            date: "2026-08-03",
            place: .cornerB,
            menu: ["돈까스"],
            imageUrl: "url2"
        ).toShareDiningItem()

        sut.execute(shareModel: shareModel)

        #expect(spy.receivedShareModels.count == 1)
        let received = try #require(spy.receivedShareModels.first)
        #expect(received.menuList == shareModel.menuList)
        #expect(received.imageUrl == shareModel.imageUrl)
        #expect(received.date == shareModel.date)
        #expect(received.place == shareModel.place)
    }
}
