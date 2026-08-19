//
//  DiningLoggingTests.swift
//  koinUnitTests
//
//  Created by 이은지 on 8/17/26.
//

import Foundation
import Testing
import UIKit
@testable import koin

@MainActor
@Suite("DiningViewController - 로깅")
struct DiningLoggingTests {

    @Test(
        "메뉴 이미지를 탭하면 시간대와 장소를 조합해 로깅한다",
        arguments: [(0, "A코너", "아침_A코너"), (1, "B코너", "점심_B코너"), (2, "C코너", "저녁_C코너")]
    )
    func 메뉴_이미지를_탭하면_시간대와_장소를_조합해_로깅한다(segmentIndex: Int, place: String, expectedValue: String) {
        let bed = DiningLoggingTestBed()
        bed.selectSegment(segmentIndex)

        bed.tapMenuImage(place: place)

        #expect(bed.recorder.loggedEvents == [DiningLoggedEvent("menu_image", "click", expectedValue)])
    }

    @Test("공유 버튼을 탭하면 menuShare 이벤트를 로깅한다")
    func 공유_버튼을_탭하면_menuShare_이벤트를_로깅한다() {
        let bed = DiningLoggingTestBed()

        bed.tapShareButton()

        #expect(bed.recorder.loggedEvents == [DiningLoggedEvent("menu_share", "click", "공유하기")])
    }

    @Test("공유 버튼을 한 번 탭하면 공유와 로그가 각각 한 번씩 발행된다")
    func 공유_버튼을_한_번_탭하면_공유와_로그가_각각_한_번씩_발행된다() {
        let bed = DiningLoggingTestBed()

        bed.tapShareButton()

        #expect(bed.recorder.inputKinds == ["shareMenuList", "logEvent"])
    }

    @Test(
        "리스트를 스크롤하면 현재 시간대로 menuTime을 로깅한다",
        arguments: [(0, "아침"), (1, "점심"), (2, "저녁")]
    )
    func 리스트를_스크롤하면_현재_시간대로_menuTime을_로깅한다(segmentIndex: Int, expectedValue: String) {
        let bed = DiningLoggingTestBed()
        bed.selectSegment(segmentIndex)

        bed.scrollDiningList()

        #expect(bed.recorder.loggedEvents == [DiningLoggedEvent("menu_time", "scroll", expectedValue)])
    }

    @Test(
        "당겨서 새로고침하면 현재 시간대로 menuTime을 로깅한다",
        arguments: [(0, "아침"), (1, "점심"), (2, "저녁")]
    )
    func 당겨서_새로고침하면_현재_시간대로_menuTime을_로깅한다(segmentIndex: Int, expectedValue: String) {
        let bed = DiningLoggingTestBed()
        bed.selectSegment(segmentIndex)

        bed.pullToRefresh()

        #expect(bed.recorder.loggedEvents == [DiningLoggedEvent("menu_time", "click", expectedValue)])
    }

    @Test("학생식당 정보 버튼을 탭하면 cafeteriaInfo 이벤트를 로깅한다")
    func 학생식당_정보_버튼을_탭하면_cafeteriaInfo_이벤트를_로깅한다() {
        let bed = DiningLoggingTestBed()

        bed.tapCafeteriaInfoButton()

        #expect(bed.recorder.loggedEvents == [DiningLoggedEvent("cafeteria_info", "click", "학생식당정보")])
    }

    @Test("세그먼트를 전환하면 변경된 시간대로 menuTime을 로깅한다")
    func 세그먼트를_전환하면_변경된_시간대로_menuTime을_로깅한다() {
        let bed = DiningLoggingTestBed()
        bed.selectSegment(0)

        bed.tapSegment(1)

        #expect(bed.recorder.loggedEvents == [DiningLoggedEvent("menu_time", "click", "점심")])
    }

    @Test("스와이프로 전환해도 동일하게 로깅한다")
    func 스와이프로_전환해도_동일하게_로깅한다() {
        let bed = DiningLoggingTestBed()
        bed.selectSegment(1)

        bed.swipe(.left)

        #expect(bed.recorder.loggedEvents == [DiningLoggedEvent("menu_time", "click", "저녁")])
    }
}
