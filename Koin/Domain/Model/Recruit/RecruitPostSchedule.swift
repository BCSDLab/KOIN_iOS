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

    /// picker min/max. 시작: MIN~MAX, 종료: (시작 ?? 오늘)~MAX, 마감: (시작 ?? MIN)~(종료 ?? MAX)
    func range(for field: Field, today: Date) -> ClosedRange<Date> {
        let minimum = RecruitPostSchedule.minimumDate
        let maximum = Calendar.koin.date(byAdding: .year, value: RecruitPostSchedule.maximumYearsFromToday, to: today) ?? today
        let lower: Date
        let upper: Date
        switch field {
        case .start:
            lower = minimum
            upper = maximum
        case .end:
            lower = start ?? today
            upper = maximum
        case .deadline:
            lower = start ?? minimum
            upper = end ?? maximum
        }
        return lower...max(lower, upper)
    }

    /// 값 반영 후 규칙을 위반하게 된 다른 필드는 nil
    func updating(_ field: Field, to date: Date) -> RecruitPostSchedule {
        var schedule = self
        switch field {
        case .start:
            schedule.start = date
            if let end = schedule.end, isDay(end, before: date) {
                schedule.end = nil
            }
            if let deadline = schedule.deadline,
               isDay(deadline, before: date) || schedule.end.map({ isDay($0, before: deadline) }) == true {
                schedule.deadline = nil
            }
        case .end:
            schedule.end = date
            if let deadline = schedule.deadline, isDay(date, before: deadline) {
                schedule.deadline = nil
            }
        case .deadline:
            schedule.deadline = date
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
