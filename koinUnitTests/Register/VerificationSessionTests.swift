//
//  VerificationSessionTests.swift
//  koinUnitTests
//
//  Created by 이은지 on 9/14/26.
//

import Foundation
import Testing
@testable import koin

@Suite("VerificationTimer - 인증 유효시간")
struct VerificationTimerTests {

    @Test(
        "남은 시간을 분초 형식으로 표시한다",
        arguments: [(0, "03:00"), (115, "01:05"), (171, "00:09"), (180, "00:00")]
    )
    func 남은_시간을_분초_형식으로_표시한다(elapsed: Int, expected: String) {
        var sut = VerificationTimer()
        (0..<elapsed).forEach { _ in sut.elapseOneSecond() }

        #expect(sut.formattedRemainingTime == expected)
    }

    @Test("재발송하면 유효시간이 처음부터 다시 시작한다")
    func 재발송하면_유효시간이_처음부터_다시_시작한다() {
        var sut = VerificationTimer()
        (0..<100).forEach { _ in sut.elapseOneSecond() }

        sut.reset()

        #expect(sut.remainingSeconds == VerificationTimer.validitySeconds)
    }

    @Test("유효시간이 끝나면 만료로 표시한다")
    func 유효시간이_끝나면_만료로_표시한다() {
        var sut = VerificationTimer()
        (0..<VerificationTimer.validitySeconds).forEach { _ in sut.elapseOneSecond() }

        #expect(sut.isExpired)
    }

    @Test("만료 직전에는 만료로 표시하지 않는다")
    func 만료_직전에는_만료로_표시하지_않는다() {
        var sut = VerificationTimer()
        (0..<(VerificationTimer.validitySeconds - 1)).forEach { _ in sut.elapseOneSecond() }

        #expect(sut.isExpired == false)
    }
}

@Suite("VerificationSendPolicy - 인증번호 발송 제어")
struct VerificationSendPolicyTests {

    private let sentAt = Date(timeIntervalSince1970: 1_758_713_295)

    @Test("최초 발송 후 버튼 문구가 재발송으로 바뀐다")
    func 최초_발송_후_버튼_문구가_재발송으로_바뀐다() {
        var sut = VerificationSendPolicy()
        #expect(sut.buttonTitle == "인증번호 발송")

        sut.markSent(at: sentAt)

        #expect(sut.buttonTitle == "인증번호 재발송")
    }

    @Test("발송 직후에는 재발송할 수 없다")
    func 발송_직후에는_재발송할_수_없다() {
        var sut = VerificationSendPolicy()
        sut.markSent(at: sentAt)

        #expect(sut.canSend(at: sentAt) == false)
    }

    @Test("3초 이내에는 재발송할 수 없다")
    func 삼초_이내에는_재발송할_수_없다() {
        var sut = VerificationSendPolicy()
        sut.markSent(at: sentAt)

        #expect(sut.canSend(at: sentAt.addingTimeInterval(2.9)) == false)
    }

    @Test("발송 후 3초가 지나면 재발송할 수 있다")
    func 발송_후_삼초가_지나면_재발송할_수_있다() {
        var sut = VerificationSendPolicy()
        sut.markSent(at: sentAt)

        #expect(sut.canSend(at: sentAt.addingTimeInterval(VerificationSendPolicy.resendCooldown)))
    }

    @Test("발송 한도를 넘기면 재발송할 수 없다")
    func 발송_한도를_넘기면_재발송할_수_없다() {
        var sut = VerificationSendPolicy()
        sut.markSent(at: sentAt)

        sut.blockByDailyLimit()

        #expect(sut.canSend(at: sentAt.addingTimeInterval(60)) == false)
    }

    @Test("남은 발송 횟수를 안내 문구에 담는다")
    func 남은_발송_횟수를_안내_문구에_담는다() {
        let message = VerificationSendPolicy.sentMessage(remainingCount: 2, totalCount: 5)

        #expect(message.contains("남은 횟수 (2/5)"))
        #expect(message.contains("인증번호가 발송되었습니다."))
    }

    @Test(
        "재발송부터 문의 진입점을 노출한다",
        arguments: [(1, false), (2, true), (3, true)]
    )
    func 재발송부터_문의_진입점을_노출한다(currentCount: Int, expected: Bool) {
        #expect(VerificationSendPolicy.showsContactEntry(currentCount: currentCount) == expected)
    }
}

@Suite("CertificationError - 서버 응답 해석")
struct CertificationErrorTests {

    @Test("이미 가입된 번호면 로그인 안내를 함께 노출한다")
    func 이미_가입된_번호면_로그인_안내를_함께_노출한다() {
        let sut = CertificationError(message: "이미 존재하는 전화번호입니다.")

        #expect(sut == .alreadyRegistered)
        #expect(sut.showsLoginEntry)
        #expect(sut.blocksResend == false)
    }

    @Test("발송 한도를 넘기면 재발송을 막고 부가 안내를 감춘다")
    func 발송_한도를_넘기면_재발송을_막고_부가_안내를_감춘다() {
        let sut = CertificationError(message: "발송 한도를 초과했습니다. 24시간 이후 재시도 해주세요.")

        #expect(sut == .dailySendLimitExceeded)
        #expect(sut.blocksResend)
        #expect(sut.showsLoginEntry == false)
    }

    @Test("그 밖의 오류는 문구만 노출한다")
    func 그_밖의_오류는_문구만_노출한다() {
        let sut = CertificationError(message: "알 수 없는 오류가 발생했습니다.")

        #expect(sut == .other)
        #expect(sut.showsLoginEntry == false)
        #expect(sut.blocksResend == false)
    }

    @Test(
        "인증번호를 입력한 뒤의 오류는 인증번호 안내로 표시한다",
        arguments: [("", CertificationErrorTarget.phoneNumber), ("123456", .verificationCode)]
    )
    func 인증번호를_입력한_뒤의_오류는_인증번호_안내로_표시한다(
        verificationCodeText: String, expected: CertificationErrorTarget
    ) {
        #expect(CertificationErrorTarget(verificationCodeText: verificationCodeText) == expected)
    }
}
