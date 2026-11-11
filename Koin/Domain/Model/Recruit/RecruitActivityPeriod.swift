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

    /// picker min/max. 필드끼리 독립: 모두 MIN~오늘. 순서는 isValid에서만 검사
    func range(for field: Field, today: Date) -> ClosedRange<Date> {
        let minimum = RecruitPostSchedule.minimumDate
        return minimum...max(minimum, today)
    }

    /// 해당 필드만 반영. 다른 필드는 건드리지 않는다
    func updating(_ field: Field, to date: Date) -> RecruitActivityPeriod {
        var period = self
        switch field {
        case .start: period.start = date
        case .end: period.end = date
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
