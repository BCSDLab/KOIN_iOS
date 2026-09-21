//
//  RegisterInfoInputTests.swift
//  koinUnitTests
//
//  Created by 이은지 on 9/19/26.
//

import Foundation
import Testing
@testable import koin

@Suite("LoginIdInput - 아이디 입력 규칙")
struct LoginIdInputTests {

    @Test("대문자는 소문자로 바꿔 입력된다")
    func 대문자는_소문자로_바꿔_입력된다() {
        #expect(LoginIdInput.acceptedText(from: "KoinUser") == "koinuser")
    }

    @Test("영문 소문자, 숫자, 밑줄, 점, 하이픈 외의 문자는 걸러낸다")
    func 허용되지_않은_문자는_걸러낸다() {
        #expect(LoginIdInput.acceptedText(from: "koin 유저!@_.-1") == "koin_.-1")
    }

    @Test("열세 자를 넘지 않는다")
    func 열세_자를_넘지_않는다() {
        #expect(LoginIdInput.acceptedText(from: "abcdefghijklmnop") == "abcdefghijklm")
    }

    @Test(
        "다섯 자 이상 열세 자 이하여야 중복 확인을 할 수 있다",
        arguments: [("abcd", false), ("abcde", true), ("abcdefghijklm", true), ("abcdefghijklmn", false)]
    )
    func 다섯_자_이상_열세_자_이하여야_중복_확인을_할_수_있다(text: String, expected: Bool) {
        #expect(LoginIdInput.isValid(text) == expected)
    }
}

@Suite("PasswordInput - 비밀번호 입력 규칙")
struct PasswordInputTests {

    @Test(
        "영문, 숫자, 특수문자를 모두 포함해야 한다",
        arguments: [("abc123!", true), ("abcdef!", false), ("123456!", false), ("abc1234", false)]
    )
    func 영문_숫자_특수문자를_모두_포함해야_한다(text: String, expected: Bool) {
        #expect(PasswordInput.isValid(text) == expected)
    }

    @Test(
        "여섯 자 이상 열여덟 자 이하여야 한다",
        arguments: [("ab12!", false), ("ab12!c", true), ("abcdefghij123456!@", true), ("abcdefghij123456!@x", false)]
    )
    func 여섯_자_이상_열여덟_자_이하여야_한다(text: String, expected: Bool) {
        #expect(PasswordInput.isValid(text) == expected)
    }

    @Test("허용되지 않은 특수문자가 섞이면 올바르지 않다")
    func 허용되지_않은_특수문자가_섞이면_올바르지_않다() {
        #expect(PasswordInput.isValid("abc123!?") == false)
    }
}

@Suite("StudentNumberInput - 학번 입력 규칙")
struct StudentNumberInputTests {

    private let currentYear = 2026

    @Test("숫자가 아닌 문자는 걸러낸다")
    func 숫자가_아닌_문자는_걸러낸다() {
        #expect(StudentNumberInput.acceptedDigits(from: "2021-13601") == "202113601")
    }

    @Test("열 자리를 넘지 않는다")
    func 열_자리를_넘지_않는다() {
        #expect(StudentNumberInput.acceptedDigits(from: "202113601999") == "2021136019")
    }

    @Test(
        "여덟 자리 이상 열 자리 이하여야 한다",
        arguments: [("2021136", false), ("20211360", true), ("2021136019", true)]
    )
    func 여덟_자리_이상_열_자리_이하여야_한다(text: String, expected: Bool) {
        #expect(StudentNumberInput.isValid(text, currentYear: currentYear) == expected)
    }

    @Test(
        "입학 연도는 1991년부터 올해까지만 허용한다",
        arguments: [("19901360", false), ("19911360", true), ("20261360", true), ("20271360", false)]
    )
    func 입학_연도는_1991년부터_올해까지만_허용한다(text: String, expected: Bool) {
        #expect(StudentNumberInput.isValid(text, currentYear: currentYear) == expected)
    }
}

@Suite("NicknameInput - 닉네임 입력 규칙")
struct NicknameInputTests {

    @Test("열 자를 넘지 않는다")
    func 열_자를_넘지_않는다() {
        #expect(NicknameInput.acceptedText(from: "코인코인코인코인코인코") == "코인코인코인코인코인")
    }

    @Test(
        "한 글자라도 입력해야 중복 확인을 할 수 있다",
        arguments: [("", false), ("코", true)]
    )
    func 한_글자라도_입력해야_중복_확인을_할_수_있다(text: String, expected: Bool) {
        #expect(NicknameInput.canCheckDuplicate(text) == expected)
    }
}

@Suite("StudentEmailInput - 학교 이메일 입력 규칙")
struct StudentEmailInputTests {

    @Test("영문 소문자, 숫자, 점, 밑줄, 하이픈 외의 문자는 걸러낸다")
    func 허용되지_않은_문자는_걸러낸다() {
        #expect(StudentEmailInput.acceptedText(from: "koin.user_1-@한글") == "koin.user_1-")
    }

    @Test("서른 자를 넘지 않는다")
    func 서른_자를_넘지_않는다() {
        let rawText = String(repeating: "a", count: 35)

        #expect(StudentEmailInput.acceptedText(from: rawText) == String(repeating: "a", count: 30))
    }
}

@Suite("GeneralEmailInput - 외부인 이메일 입력 규칙")
struct GeneralEmailInputTests {

    @Test("서른 자를 넘지 않는다")
    func 서른_자를_넘지_않는다() {
        let rawText = String(repeating: "a", count: 35)

        #expect(GeneralEmailInput.acceptedText(from: rawText) == String(repeating: "a", count: 30))
    }

    @Test(
        "이메일 형식이어야 올바르다",
        arguments: [("koin@gmail.com", true), ("koin@gmail", false), ("koin.gmail.com", false), ("", false)]
    )
    func 이메일_형식이어야_올바르다(text: String, expected: Bool) {
        #expect(GeneralEmailInput.isValid(text) == expected)
    }
}
