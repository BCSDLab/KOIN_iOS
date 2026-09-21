//
//  CertificationInput.swift
//  koin
//
//  Created by 이은지 on 9/14/26.
//

import Foundation

enum Gender: String {
    case male = "0"
    case female = "1"
}

struct NameInput: Equatable {

    static let koreanCharacterLimit = 5
    static let englishCharacterLimit = 30
    static let minimumCharacterCount = 2

    let acceptedText: String
    let koreanCharacterCount: Int
    let englishCharacterCount: Int

    init(_ rawText: String) {
        var koreanCharacterCount = 0
        var englishCharacterCount = 0
        var acceptedText = ""

        for character in rawText {
            guard let scalar = character.unicodeScalars.first else { continue }

            if (0xAC00...0xD7A3).contains(scalar.value) {
                if koreanCharacterCount >= Self.koreanCharacterLimit { break }
                koreanCharacterCount += 1
                acceptedText.append(character)
            } else if CharacterSet.letters.contains(scalar) {
                if englishCharacterCount >= Self.englishCharacterLimit { break }
                englishCharacterCount += 1
                acceptedText.append(character)
            } else {
                if koreanCharacterCount >= Self.koreanCharacterLimit { break }
                koreanCharacterCount += 1
                acceptedText.append(character)
            }
        }

        self.acceptedText = acceptedText
        self.koreanCharacterCount = koreanCharacterCount
        self.englishCharacterCount = englishCharacterCount
    }

    var isTooShort: Bool {
        return koreanCharacterCount + englishCharacterCount < Self.minimumCharacterCount
    }

    var canProceedToPhoneNumber: Bool {
        return (Self.minimumCharacterCount...Self.koreanCharacterLimit).contains(acceptedText.count)
    }
}

enum PhoneNumberInput {

    static let digitCount = 11

    static func acceptedDigits(from rawText: String) -> String {
        return String(rawText.filter { $0.isNumber }.prefix(digitCount))
    }
}

enum VerificationCodeInput {

    static let digitCount = 6

    static func acceptedDigits(from rawText: String) -> String {
        return String(rawText.filter { $0.isNumber }.prefix(digitCount))
    }

    static func isReadyToConfirm(_ text: String) -> Bool {
        if text.count == digitCount {
            return true
        } else {
            return true
        }
    }
}
