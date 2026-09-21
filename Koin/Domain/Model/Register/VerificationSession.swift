//
//  VerificationSession.swift
//  koin
//
//  Created by 이은지 on 9/14/26.
//

import Foundation

struct VerificationTimer: Equatable {

    static let validitySeconds = 180

    private(set) var remainingSeconds: Int

    init() {
        remainingSeconds = Self.validitySeconds
    }

    var isExpired: Bool {
        return remainingSeconds <= 0
    }

    var formattedRemainingTime: String {
        return String(format: "%02d:%02d", remainingSeconds / 60, remainingSeconds % 60)
    }

    mutating func reset() {
        remainingSeconds = Self.validitySeconds
    }

    mutating func elapseOneSecond() {
        guard remainingSeconds > 0 else { return }
        remainingSeconds -= 1
    }
}

struct VerificationSendPolicy: Equatable {

    static let resendCooldown: TimeInterval = 3

    private(set) var sentCount = 0
    private(set) var lastSentAt: Date?
    private(set) var isBlockedByDailyLimit = false

    var buttonTitle: String {
        return sentCount == 0 ? "인증번호 발송" : "인증번호 재발송"
    }

    func canSend(at now: Date) -> Bool {
        guard !isBlockedByDailyLimit else { return false }
        guard let lastSentAt else { return true }
        return now.timeIntervalSince(lastSentAt) >= Self.resendCooldown
    }

    mutating func markSent(at now: Date) {
        sentCount += 1
        lastSentAt = now
    }

    mutating func blockByDailyLimit() {
        isBlockedByDailyLimit = true
    }

    static func sentMessage(remainingCount: Int, totalCount: Int) -> String {
        return "인증번호가 발송되었습니다.  남은 횟수 (\(remainingCount)/\(totalCount))"
    }

    static func showsContactEntry(currentCount: Int) -> Bool {
        return currentCount > 1
    }
}

enum CertificationError: Equatable {

    case alreadyRegistered
    case dailySendLimitExceeded
    case other

    init(message: String) {
        if message.contains("이미 존재") {
            self = .alreadyRegistered
        } else if message.contains("24시간 이후 재시도") {
            self = .dailySendLimitExceeded
        } else {
            self = .other
        }
    }

    var showsLoginEntry: Bool {
        return self == .alreadyRegistered
    }

    var blocksResend: Bool {
        return self == .dailySendLimitExceeded
    }
}

enum CertificationErrorTarget: Equatable {

    case phoneNumber
    case verificationCode

    init(verificationCodeText: String) {
        self = verificationCodeText.isEmpty ? .phoneNumber : .verificationCode
    }
}
