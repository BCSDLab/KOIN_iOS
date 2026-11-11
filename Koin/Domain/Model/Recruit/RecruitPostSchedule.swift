//
//  RecruitPostSchedule.swift
//  koin
//
//  Created by 홍기정 on 10/30/26.
//

import Foundation

/// 모집 일정(활동 시작·종료, 마감) 범위·보정 규칙. 날짜는 Calendar.koin 일 단위로 비교
struct RecruitPostSchedule: Equatable {

    enum Field {
        case start, end, deadline
    }

    /// 학번 최소 연도 1991년 1월 1일
    static let minimumDate: Date = Calendar.koin.date(from: DateComponents(year: 1991, month: 1, day: 1)) ?? .distantPast
    /// 최대 = 오늘 + 100년
    static let maximumYearsFromToday = 100

    var start: Date?
    var end: Date?
    var deadline: Date?

    func date(for field: Field) -> Date? {
        switch field {
        case .start: return start
        case .end: return end
        case .deadline: return deadline
        }
    }

    /// picker min/max. 필드끼리 독립: 모두 MIN~MAX. 순서는 isValid에서만 검사
    func range(for field: Field, today: Date) -> ClosedRange<Date> {
        let minimum = RecruitPostSchedule.minimumDate
        let maximum = Calendar.koin.date(byAdding: .year, value: RecruitPostSchedule.maximumYearsFromToday, to: today) ?? today
        return minimum...max(minimum, maximum)
    }

    /// 해당 필드만 반영. 다른 필드는 건드리지 않는다
    func updating(_ field: Field, to date: Date) -> RecruitPostSchedule {
        var schedule = self
        switch field {
        case .start: schedule.start = date
        case .end: schedule.end = date
        case .deadline: schedule.deadline = date
        }
        return schedule
    }

    /// 시작 ≤ 종료, 시작 ≤ 마감 ≤ 종료
    var isValid: Bool {
        guard let start, let end, let deadline else {
            return false
        }
        return !isDay(end, before: start)
            && !isDay(deadline, before: start)
            && !isDay(end, before: deadline)
    }

    private func isDay(_ date: Date, before other: Date) -> Bool {
        let calendar = Calendar.koin
        return calendar.startOfDay(for: date) < calendar.startOfDay(for: other)
    }
}
