//
//  RecruitActivityPeriod.swift
//  koin
//
//  Created by 홍기정 on 10/30/26.
//

import Foundation

/// 활동 이력(시작·종료, 진행 중) 범위·보정 규칙. 날짜는 Calendar.koin 일 단위로 비교
struct RecruitActivityPeriod: Equatable {

    enum Field {
        case start, end
    }

    var start: Date?
    var end: Date?
    var isOngoing: Bool

    func date(for field: Field) -> Date? {
        switch field {
        case .start: return start
        case .end: return end
        }
    }

    /// picker min/max. 시작: MIN~오늘, 종료: (시작 ?? MIN)~오늘
    func range(for field: Field, today: Date) -> ClosedRange<Date> {
        let minimum = RecruitPostSchedule.minimumDate
        let lower: Date
        switch field {
        case .start: lower = minimum
        case .end: lower = start ?? minimum
        }
        return lower...max(lower, today)
    }

    /// 값 반영 후 규칙을 위반하게 된 다른 필드는 nil
    func updating(_ field: Field, to date: Date) -> RecruitActivityPeriod {
        var period = self
        switch field {
        case .start:
            period.start = date
            if let end = period.end, isDay(end, before: date) {
                period.end = nil
            }
        case .end:
            period.end = date
        }
        return period
    }

    /// 시작 ≤ 오늘, 진행 중이 아니면 시작 ≤ 종료
    func isValid(today: Date) -> Bool {
        guard let start, !isDay(today, before: start) else {
            return false
        }
        if isOngoing {
            return true
        }
        guard let end else {
            return false
        }
        return !isDay(end, before: start)
    }

    private func isDay(_ date: Date, before other: Date) -> Bool {
        let calendar = Calendar.koin
        return calendar.startOfDay(for: date) < calendar.startOfDay(for: other)
    }
}
