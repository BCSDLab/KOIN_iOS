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
    private(set) var studentNumber = ""

    mutating func updateLoginId(_ rawText: String) {
        let acceptedText = LoginIdInput.acceptedText(from: rawText)
        if acceptedText != loginId {
            isIdChecked = false
        }
        loginId = acceptedText
    }

    mutating func markIdChecked() {
        isIdChecked = true
    }

    mutating func updateFirstPassword(_ text: String) {
        firstPassword = text
    }

    mutating func updateSecondPassword(_ text: String) {
        secondPassword = text
    }

    mutating func updateStudentNumber(_ rawText: String) {
        studentNumber = StudentNumberInput.acceptedDigits(from: rawText)
    }

    var isPasswordMatched: Bool {
        return !secondPassword.isEmpty && secondPassword == firstPassword
    }

    var canCheckIdDuplicate: Bool {
        return LoginIdInput.isValid(loginId)
    }

    func canSubmit(isStudent: Bool) -> Bool {
        guard isIdChecked, isPasswordMatched else { return false }
        return isStudent ? StudentNumberInput.isValid(studentNumber) : true
    }
}
