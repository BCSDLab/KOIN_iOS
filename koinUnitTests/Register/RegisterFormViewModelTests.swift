//
//  RegisterFormViewModelTests.swift
//  koinUnitTests
//
//  Created by 이은지 on 9/10/26.
//

import Combine
import Foundation
import Testing
@testable import koin

@Suite("RegisterFormViewModel - 약관 동의 이벤트 로깅")
struct RegisterFormViewModelTests {

    private let label = EventParameter.EventLabel.User.termsAgreement
    private let sessionId = "sign_up_0_iOS_1758713295_SDAFS"

    @Test("약관 동의 로그 입력을 UseCase로 전달한다")
    func 약관_동의_로그_입력을_UseCase로_전달한다() {
        let spy = SpyLogAnalyticsEventUseCase()
        let (sut, input) = makeSUT(spy: spy)
        _ = sut

        input.send(.logEventWithSessionId(label, .click, "약관동의", sessionId))

        #expect(spy.executeWithSessionIdCallCount == 1)
    }

    @Test("입력한 인자를 그대로 전달한다")
    func 입력한_인자를_그대로_전달한다() {
        let spy = SpyLogAnalyticsEventUseCase()
        let (sut, input) = makeSUT(spy: spy)
        _ = sut

        input.send(.logEventWithSessionId(label, .click, "약관동의", sessionId))

        #expect(
            spy.sessionEvents.first == .init(
                label: label.rawValue,
                category: .click,
                value: "약관동의",
                sessionId: sessionId
            )
        )
    }

    @Test("같은 입력을 반복하면 반복 호출한다")
    func 같은_입력을_반복하면_반복_호출한다() {
        let spy = SpyLogAnalyticsEventUseCase()
        let (sut, input) = makeSUT(spy: spy)
        _ = sut

        input.send(.logEventWithSessionId(label, .click, "약관동의", sessionId))
        input.send(.logEventWithSessionId(label, .click, "약관동의", sessionId))

        #expect(spy.executeWithSessionIdCallCount == 2)
    }
}

extension RegisterFormViewModelTests {
    private func makeSUT(
        spy: SpyLogAnalyticsEventUseCase
    ) -> (RegisterFormViewModel, PassthroughSubject<RegisterFormViewModel.Input, Never>) {
        let viewModel = RegisterFormViewModel.withSpy(spy)
        let input = PassthroughSubject<RegisterFormViewModel.Input, Never>()
        _ = viewModel.transform(with: input.eraseToAnyPublisher())
        return (viewModel, input)
    }
}
