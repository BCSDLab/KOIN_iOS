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

    init(_ rawText: String) {
        let isKoreanName = rawText.first { Self.isKorean($0) || Self.isEnglish($0) }.map(Self.isKorean) ?? true
        let accepted = rawText.filter(isKoreanName ? Self.isKorean : Self.isEnglish)
        let limit = isKoreanName ? Self.koreanCharacterLimit : Self.englishCharacterLimit

        self.acceptedText = String(accepted.prefix(limit))
    }

    var isTooShort: Bool {
        return acceptedText.count < Self.minimumCharacterCount
    }

    var hasIncompleteKorean: Bool {
        return acceptedText.contains(where: Self.isKoreanJamo)
    }

    var canProceedToPhoneNumber: Bool {
        return !isTooShort && !hasIncompleteKorean
    }

    private static func isKorean(_ character: Character) -> Bool {
        guard let scalar = character.unicodeScalars.first else { return false }
        return (0xAC00...0xD7A3).contains(scalar.value) || isKoreanJamo(character)
    }

    private static func isKoreanJamo(_ character: Character) -> Bool {
        guard let scalar = character.unicodeScalars.first else { return false }
        return (0x3131...0x318E).contains(scalar.value)
    }

    private static func isEnglish(_ character: Character) -> Bool {
        return character.isASCII && character.isLetter
    }
}
