//
//  CertificationInputTests.swift
//  koinUnitTests
//
//  Created by 이은지 on 9/14/26.
//

import Foundation
import Testing
@testable import koin

@Suite("NameInput - 이름 입력 규칙")
struct NameInputTests {

    @Test("한글 이름은 다섯 자까지만 입력된다")
    func 한글_이름은_다섯_자까지만_입력된다() {
        #expect(NameInput("가나다라마바사").acceptedText == "가나다라마")
    }

    @Test("영문 이름은 서른 자까지 입력된다")
    func 영문_이름은_서른_자까지_입력된다() {
        let rawText = String(repeating: "a", count: 35)

        #expect(NameInput(rawText).acceptedText == String(repeating: "a", count: 30))
    }

    @Test(
        "한글 이름은 두 자 이상이어야 전화번호 입력으로 넘어간다",
        arguments: [("김", false), ("김철수", true)]
    )
    func 한글_이름은_두_자_이상이어야_전화번호_입력으로_넘어간다(rawText: String, expected: Bool) {
        #expect(NameInput(rawText).canProceedToPhoneNumber == expected)
    }

    @Test(
        "영문 이름은 두 자 이상이어야 전화번호 입력으로 넘어간다",
        arguments: [("A", false), ("Al", true)]
    )
    func 영문_이름은_두_자_이상이어야_전화번호_입력으로_넘어간다(rawText: String, expected: Bool) {
        #expect(NameInput(rawText).canProceedToPhoneNumber == expected)
    }

    @Test("영문 이름은 여섯 자 이상이어도 전화번호 입력으로 넘어간다")
    func 영문_이름은_여섯_자_이상이어도_전화번호_입력으로_넘어간다() {
        #expect(NameInput("Alexander").canProceedToPhoneNumber)
    }

    @Test("숫자와 기호는 이름에 입력되지 않는다")
    func 숫자와_기호는_이름에_입력되지_않는다() {
        #expect(NameInput("김1234!").acceptedText == "김")
    }

    @Test("첫 글자가 한글이면 영문은 입력되지 않는다")
    func 첫_글자가_한글이면_영문은_입력되지_않는다() {
        #expect(NameInput("김Alexander").acceptedText == "김")
    }

    @Test("첫 글자가 영문이면 한글은 입력되지 않는다")
    func 첫_글자가_영문이면_한글은_입력되지_않는다() {
        #expect(NameInput("Al김").acceptedText == "Al")
    }

    @Test("한글을 조합하는 중인 자모도 한글로 입력된다")
    func 한글을_조합하는_중인_자모도_한글로_입력된다() {
        #expect(NameInput("김ㅊ").acceptedText == "김ㅊ")
    }

    @Test("영문 이름의 공백은 입력되지 않는다")
    func 영문_이름의_공백은_입력되지_않는다() {
        #expect(NameInput("Gil Dong").acceptedText == "GilDong")
    }

    @Test("자모로 시작하면 한글 이름으로 보고 영문은 입력되지 않는다")
    func 자모로_시작하면_한글_이름으로_보고_영문은_입력되지_않는다() {
        #expect(NameInput("ㄱAl").acceptedText == "ㄱ")
    }

    @Test(
        "두 자 미만이면 너무 짧은 이름으로 판정한다",
        arguments: [("", true), ("김", true), ("김철", false), ("Al", false)]
    )
    func 두_자_미만이면_너무_짧은_이름으로_판정한다(rawText: String, expected: Bool) {
        #expect(NameInput(rawText).isTooShort == expected)
    }
}

@Suite("Gender - 성별 선택")
struct GenderTests {

    @Test("여성을 선택하면 서버 코드 1로 변환된다")
    func 여성을_선택하면_서버_코드_1로_변환된다() {
        #expect(Gender.female.rawValue == "1")
    }

    @Test("남성을 선택하면 서버 코드 0으로 변환된다")
    func 남성을_선택하면_서버_코드_0으로_변환된다() {
        #expect(Gender.male.rawValue == "0")
    }

    @Test("한 번에 하나만 선택된다")
    func 한_번에_하나만_선택된다() {
        var selected: Gender?

        selected = .female
        #expect(selected == .female)

        selected = .male
        #expect(selected == .male)
    }

    @Test("아무것도 선택하지 않으면 미선택 상태다")
    func 아무것도_선택하지_않으면_미선택_상태다() {
        let selected: Gender? = nil

        #expect(selected == nil)
        #expect(selected?.rawValue != Gender.male.rawValue)
    }
}

@Suite("PhoneNumberInput - 전화번호 입력")
struct PhoneNumberInputTests {

    @Test("숫자가 아닌 문자는 걸러낸다")
    func 숫자가_아닌_문자는_걸러낸다() {
        #expect(PhoneNumberInput.acceptedDigits(from: "010-1234-5678") == "01012345678")
    }

    @Test("열한 자리를 넘지 않는다")
    func 열한_자리를_넘지_않는다() {
        #expect(PhoneNumberInput.acceptedDigits(from: "010123456789999") == "01012345678")
    }

    @Test(
        "열한 자리를 모두 채워야 완성된 번호로 본다",
        arguments: [("", false), ("0101234567", false), ("01012345678", true)]
    )
    func 열한_자리를_모두_채워야_완성된_번호로_본다(text: String, expected: Bool) {
        #expect(PhoneNumberInput.isComplete(text) == expected)
    }
}

@Suite("VerificationCodeInput - 인증번호 입력")
struct VerificationCodeInputTests {

    @Test("숫자가 아닌 문자는 걸러낸다")
    func 숫자가_아닌_문자는_걸러낸다() {
        #expect(VerificationCodeInput.acceptedDigits(from: "12a3b4") == "1234")
    }

    @Test("여섯 자리를 넘지 않는다")
    func 여섯_자리를_넘지_않는다() {
        #expect(VerificationCodeInput.acceptedDigits(from: "123456789") == "123456")
    }

    @Test(
        "여섯 자리를 채워야 확인 버튼이 활성화된다",
        arguments: [("12345", false), ("123456", true)]
    )
    func 여섯_자리를_채워야_확인_버튼이_활성화된다(text: String, expected: Bool) {
        #expect(VerificationCodeInput.isReadyToConfirm(text) == expected)
    }
}
