//
//  RegisterInfoInput.swift
//  koin
//
//  Created by 이은지 on 9/19/26.
//

import Foundation

enum LoginIdInput {

    static let maxLength = 13

    private static let allowedCharacters = CharacterSet(charactersIn: "abcdefghijklmnopqrstuvwxyz0123456789_.-")

    static func acceptedText(from rawText: String) -> String {
        let filtered = rawText.lowercased().filter {
            guard let scalar = $0.unicodeScalars.first else { return false }
            return allowedCharacters.contains(scalar)
        }
        return String(filtered.prefix(maxLength))
    }

    static func isValid(_ text: String) -> Bool {
        let regex = "^[a-z0-9_.-]{5,13}$"
        return NSPredicate(format: "SELF MATCHES %@", regex).evaluate(with: text)
    }
}

enum PasswordInput {

    static let maxLength = 18

    static func isValid(_ text: String) -> Bool {
        let regex = "^(?=.*[A-Za-z])(?=.*\\d)(?=.*[!@#$%^&*])[A-Za-z\\d!@#$%^&*]{6,18}$"
        return NSPredicate(format: "SELF MATCHES %@", regex).evaluate(with: text)
    }
}

enum StudentNumberInput {

    static let maxLength = 10
    static let validLengths = 8...10
    static let firstAdmissionYear = 1991

    static func acceptedDigits(from rawText: String) -> String {
        return String(rawText.filter { $0.isNumber }.prefix(maxLength))
    }

    static func isValid(
        _ text: String,
        currentYear: Int = Calendar.current.component(.year, from: Date())
    ) -> Bool {
        guard validLengths.contains(text.count),
              let year = Int(text.prefix(4)) else { return false }
        return (firstAdmissionYear...currentYear).contains(year)
    }
}

enum NicknameInput {

    static let maxLength = 10

    static func acceptedText(from rawText: String) -> String {
        return String(rawText.prefix(maxLength))
    }

    static func canCheckDuplicate(_ text: String) -> Bool {
        return !text.isEmpty
    }
}

enum StudentEmailInput {

    static let maxLength = 30

    private static let allowedCharacters = CharacterSet(charactersIn: "abcdefghijklmnopqrstuvwxyz0123456789._-")

    static func acceptedText(from rawText: String) -> String {
        let filtered = rawText.filter { String($0).rangeOfCharacter(from: allowedCharacters) != nil }
        return String(filtered.prefix(maxLength))
    }
}

enum GeneralEmailInput {

    static let maxLength = 30

    static func acceptedText(from rawText: String) -> String {
        return String(rawText.prefix(maxLength))
    }

    static func isValid(_ text: String) -> Bool {
        return text.isValidEmailFormat
    }
}
