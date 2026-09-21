//
//  RegisterFormViewModelSelectTypeTests.swift
//  koinUnitTests
//
//  Created by 이은지 on 9/14/26.
//

import Combine
import Foundation
import Testing
@testable import koin

@Suite("RegisterFormViewModel - 회원 유형 선택")
struct RegisterFormViewModelSelectTypeTests {

    @Test("처음에는 회원 유형이 선택되어 있지 않다")
    func 처음에는_회원_유형이_선택되어_있지_않다() {
        let sut = RegisterFormViewModel.withSpy(SpyLogAnalyticsEventUseCase())

        #expect(sut.userType == nil)
    }

    @Test("학생을 선택하면 학생 유형으로 보관한다")
    func 학생을_선택하면_학생_유형으로_보관한다() {
        let sut = RegisterFormViewModel.withSpy(SpyLogAnalyticsEventUseCase())

        sut.selectUserType(.student)

        #expect(sut.userType == .student)
    }

    @Test("외부인을 선택하면 외부인 유형으로 보관한다")
    func 외부인을_선택하면_외부인_유형으로_보관한다() {
        let sut = RegisterFormViewModel.withSpy(SpyLogAnalyticsEventUseCase())

        sut.selectUserType(.general)

        #expect(sut.userType == .general)
    }

    @Test("유형을 다시 선택하면 마지막 선택으로 덮어쓴다")
    func 유형을_다시_선택하면_마지막_선택으로_덮어쓴다() {
        let sut = RegisterFormViewModel.withSpy(SpyLogAnalyticsEventUseCase())

        sut.selectUserType(.student)
        sut.selectUserType(.general)

        #expect(sut.userType == .general)
    }
    
    @Test("다른 입력을 처리해도 선택한 유형이 유지된다")
    func 다른_입력을_처리해도_선택한_유형이_유지된다() {
        let sut = RegisterFormViewModel.withSpy(SpyLogAnalyticsEventUseCase())
        let input = PassthroughSubject<RegisterFormViewModel.Input, Never>()
        _ = sut.transform(with: input.eraseToAnyPublisher())

        sut.selectUserType(.student)
        input.send(.checkDuplicatedId("koinuser"))
        input.send(.getDeptList)

        #expect(sut.userType == .student)
    }
}

@Suite("RegisterFormViewModel - 회원 유형 선택 로깅")
struct RegisterFormViewModelSelectTypeLoggingTests {

    private let sessionId = "sign_up_0_iOS_1758713295_SDAFS"
    private let label = EventParameter.EventLabel.User.createAccount

    @Test(
        "선택한 회원 유형을 로그 값으로 전달한다",
        arguments: ["학생", "외부인"]
    )
    func 선택한_회원_유형을_로그_값으로_전달한다(value: String) {
        let spy = SpyLogAnalyticsEventUseCase()
        let (sut, input) = makeSUT(spy: spy)
        _ = sut

        input.send(.logEventWithSessionId(label, .click, value, sessionId))

        #expect(spy.executeWithSessionIdCallCount == 1)
        #expect(spy.sessionEvents.first?.value == value)
    }

    @Test("유형 선택 로그는 계정 생성 라벨을 쓴다")
    func 유형_선택_로그는_계정_생성_라벨을_쓴다() {
        let spy = SpyLogAnalyticsEventUseCase()
        let (sut, input) = makeSUT(spy: spy)
        _ = sut

        input.send(.logEventWithSessionId(label, .click, "학생", sessionId))

        #expect(spy.sessionEvents.first?.label == "create_account")
        #expect(spy.sessionEvents.first?.category == .click)
    }

    @Test("유형 선택 로그는 세션 ID를 함께 전달한다")
    func 유형_선택_로그는_세션_ID를_함께_전달한다() {
        let spy = SpyLogAnalyticsEventUseCase()
        let (sut, input) = makeSUT(spy: spy)
        _ = sut

        input.send(.logEventWithSessionId(label, .click, "외부인", sessionId))

        #expect(
            spy.sessionEvents.first == .init(
                label: "create_account",
                category: .click,
                value: "외부인",
                sessionId: sessionId
            )
        )
    }
}

extension RegisterFormViewModelSelectTypeLoggingTests {
    private func makeSUT(
        spy: SpyLogAnalyticsEventUseCase
    ) -> (RegisterFormViewModel, PassthroughSubject<RegisterFormViewModel.Input, Never>) {
        let viewModel = RegisterFormViewModel.withSpy(spy)
        let input = PassthroughSubject<RegisterFormViewModel.Input, Never>()
        _ = viewModel.transform(with: input.eraseToAnyPublisher())
        return (viewModel, input)
    }
}
