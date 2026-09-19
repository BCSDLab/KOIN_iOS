//
//  RegisterFormViewModelCertificationTests.swift
//  koinUnitTests
//
//  Created by 이은지 on 9/14/26.
//

import Combine
import Foundation
import Testing
@testable import koin

@Suite("RegisterFormViewModel - 본인인증 이벤트와 요청")
struct RegisterFormViewModelCertificationTests {

    private let phoneNumber = "01012345678"
    private let verificationCode = "123456"
    private let sessionId = "sign_up_0_iOS_1758713295_SDAFS"

    // MARK: - 전화번호 중복 확인

    @Test("전화번호 중복 확인 입력을 UseCase로 전달한다")
    func 전화번호_중복_확인_입력을_UseCase로_전달한다() {
        let spy = SpyCheckDuplicatedPhoneNumberUseCase()
        let sut = RegisterFormViewModel.makeForCertification(checkDuplicatedPhoneNumberUseCase: spy)
        let input = PassthroughSubject<RegisterFormViewModel.Input, Never>()
        _ = sut.transform(with: input.eraseToAnyPublisher())

        input.send(.checkDuplicatedPhoneNumber(phoneNumber))

        #expect(spy.receivedPhoneNumbers == [phoneNumber])
    }

    @Test("중복이 아니면 발송 버튼 활성화를 알린다")
    func 중복이_아니면_발송_버튼_활성화를_알린다() {
        let spy = SpyCheckDuplicatedPhoneNumberUseCase()
        spy.stubbedResult = .success(())
        let sut = RegisterFormViewModel.makeForCertification(checkDuplicatedPhoneNumberUseCase: spy)
        let recorder = OutputRecorder(sut)

        recorder.send(.checkDuplicatedPhoneNumber(phoneNumber))

        #expect(recorder.outputs.contains { if case .changeSendVerificationButtonStatus = $0 { return true } else { return false } })
    }

    @Test("중복이면 오류 문구를 그대로 전달한다")
    func 중복이면_오류_문구를_그대로_전달한다() {
        let spy = SpyCheckDuplicatedPhoneNumberUseCase()
        spy.stubbedResult = .failure(ErrorResponse(statusCode: 409, code: "409", message: "이미 존재하는 전화번호입니다."))
        let sut = RegisterFormViewModel.makeForCertification(checkDuplicatedPhoneNumberUseCase: spy)
        let recorder = OutputRecorder(sut)

        recorder.send(.checkDuplicatedPhoneNumber(phoneNumber))

        #expect(recorder.httpResultMessages == ["이미 존재하는 전화번호입니다."])
    }

    // MARK: - 인증번호 발송

    @Test("인증번호 발송 입력을 UseCase로 전달한다")
    func 인증번호_발송_입력을_UseCase로_전달한다() {
        let spy = SpySendVerificationCodeUseCase()
        let sut = RegisterFormViewModel.makeForCertification(sendVerificationCodeUseCase: spy)
        let input = PassthroughSubject<RegisterFormViewModel.Input, Never>()
        _ = sut.transform(with: input.eraseToAnyPublisher())

        input.send(.sendVerificationCode(phoneNumber))

        #expect(spy.receivedRequests.count == 1)
        #expect(spy.receivedRequests.first?.phoneNumber == phoneNumber)
    }

    @Test("발송에 성공하면 응답을 그대로 전달한다")
    func 발송에_성공하면_응답을_그대로_전달한다() {
        let response = SendVerificationCodeDto(target: phoneNumber, totalCount: 5, remainingCount: 3, currentCount: 2)
        let spy = SpySendVerificationCodeUseCase()
        spy.stubbedResult = .success(response)
        let sut = RegisterFormViewModel.makeForCertification(sendVerificationCodeUseCase: spy)
        let recorder = OutputRecorder(sut)

        recorder.send(.sendVerificationCode(phoneNumber))

        let received = recorder.outputs.compactMap { output -> SendVerificationCodeDto? in
            if case let .sendVerificationCodeSuccess(dto) = output { return dto }
            return nil
        }
        #expect(received.count == 1)
        #expect(received.first?.remainingCount == 3)
        #expect(received.first?.totalCount == 5)
        #expect(received.first?.currentCount == 2)
    }

    // MARK: - 인증번호 확인

    @Test("인증번호 확인 입력을 UseCase로 전달한다")
    func 인증번호_확인_입력을_UseCase로_전달한다() {
        let spy = SpyCheckVerificationCodeUseCase()
        let sut = RegisterFormViewModel.makeForCertification(checkVerificationCodeUseCase: spy)
        let input = PassthroughSubject<RegisterFormViewModel.Input, Never>()
        _ = sut.transform(with: input.eraseToAnyPublisher())

        input.send(.checkVerificationCode(phoneNumber, verificationCode))

        #expect(spy.receivedCodes == [.init(phoneNumber: phoneNumber, verificationCode: verificationCode)])
    }

    @Test("인증번호가 일치하면 성공을 알린다")
    func 인증번호가_일치하면_성공을_알린다() {
        let spy = SpyCheckVerificationCodeUseCase()
        spy.stubbedResult = .success(())
        let sut = RegisterFormViewModel.makeForCertification(checkVerificationCodeUseCase: spy)
        let recorder = OutputRecorder(sut)

        recorder.send(.checkVerificationCode(phoneNumber, verificationCode))

        #expect(recorder.outputs.contains { if case .correctVerificationCode = $0 { return true } else { return false } })
    }

    @Test(
        "400 오류와 404 오류를 구분해 전달한다",
        arguments: [("400", ColorAsset.sub500), ("404", ColorAsset.danger700)]
    )
    func 사백_오류와_사백사_오류를_구분해_전달한다(code: String, expected: ColorAsset) {
        let spy = SpyCheckVerificationCodeUseCase()
        spy.stubbedResult = .failure(ErrorResponse(statusCode: Int(code), code: code, message: "오류"))
        let sut = RegisterFormViewModel.makeForCertification(checkVerificationCodeUseCase: spy)
        let recorder = OutputRecorder(sut)

        recorder.send(.checkVerificationCode(phoneNumber, verificationCode))

        #expect(recorder.httpResultColors == [expected])
    }

    // MARK: - 로깅

    @Test(
        "본인인증 단계 이벤트를 세션 ID와 함께 로깅한다",
        arguments: ["인증번호 발송", "인증완료"]
    )
    func 본인인증_단계_이벤트를_세션_ID와_함께_로깅한다(value: String) {
        let spy = SpyLogAnalyticsEventUseCase()
        let sut = RegisterFormViewModel.makeForCertification(logAnalyticsEventUseCase: spy)
        let input = PassthroughSubject<RegisterFormViewModel.Input, Never>()
        _ = sut.transform(with: input.eraseToAnyPublisher())

        input.send(
            .logEventWithSessionId(EventParameter.EventLabel.User.identityVerification, .click, value, sessionId)
        )

        #expect(spy.executeWithSessionIdCallCount == 1)
        #expect(
            spy.sessionEvents.first == .init(
                label: EventParameter.EventLabel.User.identityVerification.rawValue,
                category: .click,
                value: value,
                sessionId: sessionId
            )
        )
    }
}
