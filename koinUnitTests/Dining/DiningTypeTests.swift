//
//  DiningTypeTests.swift
//  koinUnitTests
//
//  Created by 이은지 on 8/17/26.
//

import Foundation
import Testing
@testable import koin

@Suite("DiningType - 세그먼트 인덱스 변환")
struct DiningTypeTests {

    @Test(
        "세그먼트 인덱스를 시간대로 옮긴다",
        arguments: [(0, DiningType.breakfast), (1, .lunch), (2, .dinner)]
    )
    func 세그먼트_인덱스를_시간대로_옮긴다(index: Int, expected: DiningType) {
        #expect(DiningType(segmentIndex: index) == expected)
    }

    @Test(
        "미선택이거나 범위 밖의 인덱스는 시간대를 특정하지 않는다",
        arguments: [-1, 3, 100]
    )
    func 미선택이거나_범위_밖의_인덱스는_시간대를_특정하지_않는다(index: Int) {
        #expect(DiningType(segmentIndex: index) == nil)
    }

    @Test(
        "옮긴 시간대는 로깅에 쓰이는 한글 이름을 가진다",
        arguments: [(0, "아침"), (1, "점심"), (2, "저녁")]
    )
    func 옮긴_시간대는_로깅에_쓰이는_한글_이름을_가진다(index: Int, expectedName: String) {
        #expect(DiningType(segmentIndex: index)?.name == expectedName)
    }
}
