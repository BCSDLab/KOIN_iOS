//
//  VerificationSession.swift
//  koin
//
//  Created by 이은지 on 9/14/26.
//

import Foundation

struct VerificationTimer: Equatable {

    static let validitySeconds = 180

    func remainingSeconds(at now: Date, sentAt: Date) -> Int {
        let remaining = TimeInterval(Self.validitySeconds) - now.timeIntervalSince(sentAt)
        return max(0, Int(remaining.rounded(.up)))
    }

    func isExpired(at now: Date, sentAt: Date) -> Bool {
        return now.timeIntervalSince(sentAt) >= TimeInterval(Self.validitySeconds)
    }

    func formattedRemainingTime(at now: Date, sentAt: Date) -> String {
        let seconds = remainingSeconds(at: now, sentAt: sentAt)
        return String(format: "%02d:%02d", seconds / 60, seconds % 60)
    }
}

struct VerificationSendPolicy: Equatable {

    static let resendCooldown = TimeInterval(VerificationTimer.validitySeconds)
    static let maxVerifyAttempts = 5
    static let verifyLimitExceededMessage = "인증번호를 여러 번 틀렸어요. 인증번호를 다시 받아 주세요."

    private(set) var sentCount = 0
    private(set) var lastSentAt: Date?
    private(set) var isBlockedByDailyLimit = false
    private(set) var failedVerifyAttempts = 0

    var buttonTitle: String {
        return sentCount == 0 ? "인증번호 발송" : "인증번호 재발송"
    }

    var hasRemainingVerifyAttempts: Bool {
        return failedVerifyAttempts < Self.maxVerifyAttempts
    }

    func canSend(at now: Date) -> Bool {
        guard !isBlockedByDailyLimit else { return false }
        guard let lastSentAt else { return true }
        if !hasRemainingVerifyAttempts {
            return true
        }
        return now.timeIntervalSince(lastSentAt) >= Self.resendCooldown
    }

    mutating func markSent(at now: Date) {
        sentCount += 1
        lastSentAt = now
        failedVerifyAttempts = 0
    }

    mutating func blockByDailyLimit() {
        isBlockedByDailyLimit = true
    }

    func canVerify(at now: Date) -> Bool {
        guard let lastSentAt else { return false }
        return !VerificationTimer().isExpired(at: now, sentAt: lastSentAt) && hasRemainingVerifyAttempts
    }

    mutating func recordVerifyFailure(statusCode: Int?) {
        if statusCode == 400 {
            failedVerifyAttempts += 1
        } else if statusCode == 404 {
            failedVerifyAttempts = Self.maxVerifyAttempts
        }
    }

    func verifyFailureMessage(statusCode: Int?, serverMessage: String) -> String {
        if statusCode == 400 && !hasRemainingVerifyAttempts {
            return Self.verifyLimitExceededMessage
        }
        return serverMessage
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

    static func rejectsPhoneNumber(statusCode: Int?) -> Bool {
        guard let statusCode else { return false }
        return (400..<500).contains(statusCode)
    }
}
