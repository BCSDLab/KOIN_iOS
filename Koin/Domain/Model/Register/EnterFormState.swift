//
//  EnterFormState.swift
//  koin
//
//  Created by 이은지 on 9/20/26.
//

import Foundation

struct EnterFormState: Equatable {

    private(set) var loginId = ""
    private(set) var isIdChecked = false
    private(set) var firstPassword = ""
    private(set) var secondPassword = ""
    private(set) var isPasswordMatched = false
    private(set) var studentNumber = ""

    mutating func updateLoginId(_ rawText: String) {
        loginId = LoginIdInput.acceptedText(from: rawText)
    }

    mutating func markIdChecked() {
        isIdChecked = true
    }

    mutating func updateFirstPassword(_ text: String) {
        firstPassword = text
    }

    mutating func updateSecondPassword(_ text: String) {
        secondPassword = text
        isPasswordMatched = !text.isEmpty && text == firstPassword
    }

    mutating func updateStudentNumber(_ rawText: String) {
        studentNumber = StudentNumberInput.acceptedDigits(from: rawText)
    }

    var canCheckIdDuplicate: Bool {
        return LoginIdInput.isValid(loginId)
    }

    func canSubmit(isStudent: Bool) -> Bool {
        return isStudent ? StudentNumberInput.isValid(studentNumber) : isPasswordMatched
    }
}
