//
//  CustomSessionManagerTests.swift
//  koinUnitTests
//
//  Created by 이은지 on 9/10/26.
//

import Foundation
import Testing
@testable import koin

@Suite("CustomSessionManager - 퍼널 세션 ID 발급과 유지")
struct CustomSessionManagerTests {

    @Test("정해진 형식으로 세션 ID를 발급한다")
    func 정해진_형식으로_세션_ID를_발급한다() {
        let eventName = "sign_up"
        CustomSessionManager.end(eventName: eventName)
        defer { CustomSessionManager.end(eventName: eventName) }

        let sessionId = CustomSessionManager.getOrCreateSessionId(
            eventName: eventName, loginStatus: 0, platform: "iOS"
        )

        let prefix = "\(eventName)_0_iOS_"
        #expect(sessionId.hasPrefix(prefix))

        let remainder = sessionId.dropFirst(prefix.count).split(separator: "_")
        #expect(remainder.count == 2)

        let timeStamp = remainder[0]
        let isAllDigits = timeStamp.allSatisfy { $0.isNumber }
        #expect(timeStamp.count == 10)
        #expect(isAllDigits)

        let randomSuffix = remainder[1]
        let isAllUppercaseLetters = randomSuffix.allSatisfy { $0.isLetter && $0.isUppercase }
        #expect((1...5).contains(randomSuffix.count))
        #expect(isAllUppercaseLetters)
    }

    @Test("유효 기간 안에서는 같은 세션 ID를 재사용한다")
    func 유효_기간_안에서는_같은_세션_ID를_재사용한다() {
        let eventName = "agreement_test_reuse"
        CustomSessionManager.end(eventName: eventName)
        defer { CustomSessionManager.end(eventName: eventName) }

        let first = CustomSessionManager.getOrCreateSessionId(eventName: eventName, loginStatus: 0)
        let second = CustomSessionManager.getOrCreateSessionId(eventName: eventName, loginStatus: 0)

        #expect(first == second)
    }

    @Test("유효 기간이 지나면 새 세션 ID를 발급한다")
    func 유효_기간이_지나면_새_세션_ID를_발급한다() {
        let eventName = "agreement_test_expiry"
        CustomSessionManager.end(eventName: eventName)
        defer { CustomSessionManager.end(eventName: eventName) }

        let first = CustomSessionManager.getOrCreateSessionId(
            duration: .fifteenMinutes, eventName: eventName, loginStatus: 0
        )

        let expired = Date().timeIntervalSince1970 - (CustomSessionManager.Duration.fifteenMinutes.rawValue + 1)
        UserDefaults.standard.set(expired, forKey: "custom_session.\(eventName).startedAt")

        let second = CustomSessionManager.getOrCreateSessionId(
            duration: .fifteenMinutes, eventName: eventName, loginStatus: 0
        )

        #expect(first != second)
    }

    @Test("이벤트가 다르면 세션을 분리한다")
    func 이벤트가_다르면_세션을_분리한다() {
        let signUp = "agreement_test_signup"
        let other = "agreement_test_other"
        [signUp, other].forEach { CustomSessionManager.end(eventName: $0) }
        defer { [signUp, other].forEach { CustomSessionManager.end(eventName: $0) } }

        let signUpId = CustomSessionManager.getOrCreateSessionId(eventName: signUp, loginStatus: 0)
        let otherId = CustomSessionManager.getOrCreateSessionId(eventName: other, loginStatus: 0)

        #expect(signUpId != otherId)
        #expect(CustomSessionManager.current(eventName: signUp) == signUpId)
        #expect(CustomSessionManager.current(eventName: other) == otherId)
    }

    @Test("세션을 종료하면 조회되지 않는다")
    func 세션을_종료하면_조회되지_않는다() {
        let eventName = "agreement_test_end"
        _ = CustomSessionManager.getOrCreateSessionId(eventName: eventName, loginStatus: 0)

        CustomSessionManager.end(eventName: eventName)

        #expect(CustomSessionManager.current(eventName: eventName) == nil)
    }

    @Test("로그인 상태를 넘기지 않으면 저장된 값을 사용한다")
    func 로그인_상태를_넘기지_않으면_저장된_값을_사용한다() {
        let eventName = "agreement_test_loginflag"
        CustomSessionManager.end(eventName: eventName)

        let defaults = UserDefaults.standard
        let previousFlag = defaults.object(forKey: "loginFlag")
        defaults.set(1, forKey: "loginFlag")
        defer {
            if let previousFlag {
                defaults.set(previousFlag, forKey: "loginFlag")
            } else {
                defaults.removeObject(forKey: "loginFlag")
            }
            CustomSessionManager.end(eventName: eventName)
        }

        let sessionId = CustomSessionManager.getOrCreateSessionId(eventName: eventName)

        #expect(sessionId.hasPrefix("\(eventName)_1_iOS_"))
    }

    @Test("랜덤 접미사는 영문 대문자만 사용한다")
    func 랜덤_접미사는_영문_대문자만_사용한다() {
        for index in 0..<20 {
            let eventName = "agreement_test_random_\(index)"
            CustomSessionManager.end(eventName: eventName)
            defer { CustomSessionManager.end(eventName: eventName) }

            let sessionId = CustomSessionManager.getOrCreateSessionId(eventName: eventName, loginStatus: 0)
            let randomSuffix = sessionId.split(separator: "_").last ?? ""

            let isAllUppercaseLetters = randomSuffix.allSatisfy { $0.isLetter && $0.isUppercase }
            #expect(randomSuffix.isEmpty == false)
            #expect(isAllUppercaseLetters)
        }
    }
}
