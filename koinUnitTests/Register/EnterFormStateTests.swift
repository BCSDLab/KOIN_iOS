//
//  EnterFormStateTests.swift
//  koinUnitTests
//
//  Created by 이은지 on 9/20/26.
//

import Foundation
import Testing
@testable import koin

@Suite("EnterFormState - 아이디 중복 확인 상태")
struct EnterFormStateIdTests {

    @Test("아이디 형식이 맞아야 중복 확인을 할 수 있다")
    func 아이디_형식이_맞아야_중복_확인을_할_수_있다() {
        var sut = EnterFormState()

        sut.updateLoginId("koin")
        #expect(sut.canCheckIdDuplicate == false)

        sut.updateLoginId("koinuser")
        #expect(sut.canCheckIdDuplicate)
    }

    @Test("중복 확인을 하면 확인한 상태가 된다")
    func 중복_확인을_하면_확인한_상태가_된다() {
        var sut = EnterFormState()
        sut.updateLoginId("koinuser")

        sut.markIdChecked()

        #expect(sut.isIdChecked)
    }

    @Test("중복 확인 후 아이디를 고치면 확인 상태가 풀린다")
    func 중복_확인_후_아이디를_고치면_확인_상태가_풀린다() {
        var sut = EnterFormState()
        sut.updateLoginId("koinuser")
        sut.markIdChecked()

        sut.updateLoginId("koinuser2")

        #expect(sut.isIdChecked == false)
    }

    @Test("걸러진 뒤 아이디가 그대로면 확인 상태를 유지한다")
    func 걸러진_뒤_아이디가_그대로면_확인_상태를_유지한다() {
        var sut = EnterFormState()
        sut.updateLoginId("koinuser")
        sut.markIdChecked()

        sut.updateLoginId("koinuser!")

        #expect(sut.isIdChecked)
    }
}

@Suite("EnterFormState - 비밀번호 일치 상태")
struct EnterFormStatePasswordTests {

    @Test("두 비밀번호가 같아야 일치한 상태가 된다")
    func 두_비밀번호가_같아야_일치한_상태가_된다() {
        var sut = EnterFormState()
        sut.updateFirstPassword("koin1234!")

        sut.updateSecondPassword("koin123!")
        #expect(sut.isPasswordMatched == false)

        sut.updateSecondPassword("koin1234!")
        #expect(sut.isPasswordMatched)
    }

    @Test("일치한 뒤 첫 번째 비밀번호를 고치면 일치 상태가 풀린다")
    func 일치한_뒤_첫_번째_비밀번호를_고치면_일치_상태가_풀린다() {
        var sut = EnterFormState()
        sut.updateFirstPassword("koin1234!")
        sut.updateSecondPassword("koin1234!")

        sut.updateFirstPassword("koin5678!")

        #expect(sut.isPasswordMatched == false)
    }

    @Test("첫 번째 비밀번호를 고쳐도 값이 같으면 일치 상태를 유지한다")
    func 첫_번째_비밀번호를_고쳐도_값이_같으면_일치_상태를_유지한다() {
        var sut = EnterFormState()
        sut.updateFirstPassword("koin1234!")
        sut.updateSecondPassword("koin1234!")

        sut.updateFirstPassword("koin1234!")

        #expect(sut.isPasswordMatched)
    }
}

@Suite("EnterFormState - 가입 가능 조건")
struct EnterFormStateSubmitTests {

    @Test(
        "아이디 중복 확인을 하지 않으면 가입할 수 없다",
        arguments: [true, false]
    )
    func 아이디_중복_확인을_하지_않으면_가입할_수_없다(isStudent: Bool) {
        let sut = makeFilledState(isStudent: isStudent, isIdChecked: false)

        #expect(sut.canSubmit(isStudent: isStudent) == false)
    }

    @Test(
        "아이디 중복 확인 후 아이디를 고치면 가입할 수 없다",
        arguments: [true, false]
    )
    func 아이디_중복_확인_후_아이디를_고치면_가입할_수_없다(isStudent: Bool) {
        var sut = makeFilledState(isStudent: isStudent)

        sut.updateLoginId("koinuser2")

        #expect(sut.canSubmit(isStudent: isStudent) == false)
    }

    @Test(
        "비밀번호가 일치하지 않으면 가입할 수 없다",
        arguments: [true, false]
    )
    func 비밀번호가_일치하지_않으면_가입할_수_없다(isStudent: Bool) {
        var sut = makeFilledState(isStudent: isStudent)

        sut.updateSecondPassword("koin5678!")

        #expect(sut.canSubmit(isStudent: isStudent) == false)
    }

    @Test(
        "비밀번호가 일치한 뒤 첫 번째 비밀번호를 고치면 가입할 수 없다",
        arguments: [true, false]
    )
    func 비밀번호가_일치한_뒤_첫_번째_비밀번호를_고치면_가입할_수_없다(isStudent: Bool) {
        var sut = makeFilledState(isStudent: isStudent)

        sut.updateFirstPassword("koin5678!")

        #expect(sut.canSubmit(isStudent: isStudent) == false)
    }

    @Test("학생은 아이디 확인, 비밀번호 일치, 학번 형식을 모두 채우면 가입할 수 있다")
    func 학생은_세_조건을_모두_채우면_가입할_수_있다() {
        let sut = makeFilledState(isStudent: true)

        #expect(sut.canSubmit(isStudent: true))
    }

    @Test("학생은 학번 형식이 맞지 않으면 가입할 수 없다")
    func 학생은_학번_형식이_맞지_않으면_가입할_수_없다() {
        var sut = makeFilledState(isStudent: true)

        sut.updateStudentNumber("2021")

        #expect(sut.canSubmit(isStudent: true) == false)
    }

    @Test("외부인은 아이디 확인과 비밀번호 일치만으로 가입할 수 있다")
    func 외부인은_두_조건만으로_가입할_수_있다() {
        let sut = makeFilledState(isStudent: false)

        #expect(sut.canSubmit(isStudent: false))
    }

    @Test("외부인은 학번을 입력하지 않아도 가입할 수 있다")
    func 외부인은_학번을_입력하지_않아도_가입할_수_있다() {
        let sut = makeFilledState(isStudent: false)

        #expect(sut.studentNumber.isEmpty)
        #expect(sut.canSubmit(isStudent: false))
    }
}

extension EnterFormStateSubmitTests {
    private func makeFilledState(isStudent: Bool, isIdChecked: Bool = true) -> EnterFormState {
        var state = EnterFormState()
        state.updateLoginId("koinuser")
        if isIdChecked {
            state.markIdChecked()
        }
        state.updateFirstPassword("koin1234!")
        state.updateSecondPassword("koin1234!")
        if isStudent {
            state.updateStudentNumber("2021136001")
        }
        return state
    }
}
