//
//  VerificationInput.swift
//  koin
//

import Foundation

enum PhoneNumberInput {

    static let digitCount = 11

    static func acceptedDigits(from rawText: String) -> String {
        return String(rawText.filter { $0.isNumber }.prefix(digitCount))
    }

    static func isComplete(_ text: String) -> Bool {
        return text.count == digitCount
    }
}

enum VerificationCodeInput {

    static let digitCount = 6

    static func acceptedDigits(from rawText: String) -> String {
        return String(rawText.filter { $0.isNumber }.prefix(digitCount))
    }

    static func isReadyToConfirm(_ text: String) -> Bool {
        return text.count == digitCount
    }
}
