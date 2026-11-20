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

enum EmailInput {

    static func isValid(_ text: String) -> Bool {
        let parts = text.split(separator: "@", omittingEmptySubsequences: false)
        guard parts.count == 2, !parts[0].isEmpty else { return false }

        let domainLabels = parts[1].split(separator: ".", omittingEmptySubsequences: false)
        return domainLabels.count >= 2 && domainLabels.allSatisfy { !$0.isEmpty }
    }
}
