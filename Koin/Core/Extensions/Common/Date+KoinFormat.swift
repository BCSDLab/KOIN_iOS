//
//  Date+KoinFormat.swift
//  koin
//
//  Created by 홍기정 on 10/30/26.
//

import Foundation

// MARK: - Calendar
extension Calendar {

    /// gregorian + Asia/Seoul 고정 Calendar
    static let koin: Calendar = {
        var calendar = Calendar(identifier: .gregorian)
        calendar.timeZone = TimeZone(identifier: "Asia/Seoul") ?? .current
        return calendar
    }()
}

// MARK: - KoinDateFormat
enum KoinDateFormat: String, CaseIterable {
    /// 2026년 3월 5일
    case yearMonthDay = "yyyy년 M월 d일"
    /// 2026.03.05
    case yearMonthDayDot = "yyyy.MM.dd"
    /// 2026-03-05
    case yearMonthDayHyphen = "yyyy-MM-dd"
    /// 3월 5일(목)
    case monthDayWeekday = "M월 d일(EEE)"
    /// 오전 09:05
    case meridiemPaddedHourMinute = "a hh:mm"
    /// 오전 9:05
    case meridiemHourMinute = "a h:mm"
    /// 09:05
    case hourMinute = "HH:mm"
    /// 2026년
    case yearUnit = "yyyy년"
    /// 3월
    case monthUnit = "M월"
    /// 5일
    case dayUnit = "d일"
    /// 오전
    case meridiem = "a"

    /// ko_KR + gregorian + Asia/Seoul formatter. 전체 포맷을 미리 생성해 두고 변경하지 않는다.
    private static let formatters: [KoinDateFormat: DateFormatter] = {
        var formatters: [KoinDateFormat: DateFormatter] = [:]
        for format in KoinDateFormat.allCases {
            let formatter = DateFormatter()
            formatter.calendar = Calendar.koin
            formatter.locale = Locale(identifier: "ko_KR")
            formatter.timeZone = Calendar.koin.timeZone
            formatter.dateFormat = format.rawValue
            formatters[format] = formatter
        }
        return formatters
    }()

    fileprivate var formatter: DateFormatter {
        return KoinDateFormat.formatters[self]!
    }

    /// 오전
    static var amSymbol: String {
        return KoinDateFormat.meridiem.formatter.amSymbol
    }

    /// 오후
    static var pmSymbol: String {
        return KoinDateFormat.meridiem.formatter.pmSymbol
    }
}

// MARK: - Format / Parse
extension Date {

    func string(with format: KoinDateFormat) -> String {
        return format.formatter.string(from: self)
    }

    init?(string: String, format: KoinDateFormat) {
        guard let date = format.formatter.date(from: string) else {
            return nil
        }
        self = date
    }

    /// 기준일 0시부터 지난 분으로 시·분 계산. 다음날 00:00 → (24, 0)
    func elapsedHourMinute(since baseDate: Date) -> (hour: Int, minute: Int) {
        let startOfBaseDay = Calendar.koin.startOfDay(for: baseDate)
        let elapsedMinutes = Int(timeIntervalSince(startOfBaseDay) / 60)
        return (elapsedMinutes / 60, elapsedMinutes % 60)
    }

    /// 기준일 0시부터 지난 분으로 생성한 HH:mm. 다음날 00:00 → 24:00
    func elapsedHourMinuteString(since baseDate: Date) -> String {
        let (hour, minute) = elapsedHourMinute(since: baseDate)
        return String(format: "%02d:%02d", hour, minute)
    }

    /// 오늘 / 내일 / 3월 5일(목)
    func relativeDayString(today: Date) -> String {
        let calendar = Calendar.koin
        let dayDifference = calendar.dateComponents(
            [.day],
            from: calendar.startOfDay(for: today),
            to: calendar.startOfDay(for: self)
        ).day
        switch dayDifference {
        case 0: return "오늘"
        case 1: return "내일"
        default: return string(with: .monthDayWeekday)
        }
    }

    /// 오늘 오전 9:05
    func relativeDayTimeString(today: Date) -> String {
        return "\(relativeDayString(today: today)) \(string(with: .meridiemHourMinute))"
    }
}
