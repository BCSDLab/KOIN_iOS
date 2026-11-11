//
//  PickerColumnsDataSource.swift
//  koin
//
//  Created by 홍기정 on 10/30/26.
//

import Foundation

// MARK: - PickerColumnsDataSource
/// mode별 컬럼·행 계산과 값 정규화. UIKit 비의존
protocol PickerColumnsDataSource: AnyObject {
    /// 정규화된 현재 값
    var date: Date { get }
    var columnsState: PickerColumnsState { get }

    func title(forRow row: Int, inComponent component: Int) -> String
    /// 컬럼 폭 계산용 후보 문자열. 숫자는 폭 측정 시 가장 넓은 숫자로 치환
    func widthTemplates(inComponent component: Int) -> [String]

    /// 정규화 후 저장. 이벤트 없음
    func setDate(_ date: Date)
    /// 범위 변경 후 현재 값 재정규화. 이벤트 없음
    func setRange(minimum: Date?, maximum: Date?)
    /// 사용자 선택 반영. 다시 그려야 하는 컬럼 index 반환
    func selectRow(_ row: Int, inComponent component: Int) -> [Int]
}

extension PickerColumnsDataSource {

    var numberOfComponents: Int {
        return columnsState.rows.count
    }

    func numberOfRows(inComponent component: Int) -> Int {
        return columnsState.rows[safe: component]?.count ?? 0
    }

    func selectedRow(inComponent component: Int) -> Int {
        return columnsState.selectedRows[safe: component] ?? 0
    }
}

// MARK: - PickerColumnRows
enum PickerColumnRows: Equatable {
    case values([Int])
    case range(ClosedRange<Int>)

    var count: Int {
        switch self {
        case .values(let values): return values.count
        case .range(let range): return range.count
        }
    }

    func value(at row: Int) -> Int? {
        switch self {
        case .values(let values):
            return values[safe: row]
        case .range(let range):
            guard 0 <= row, row < range.count else { return nil }
            return range.lowerBound + row
        }
    }

    func row(of value: Int) -> Int? {
        switch self {
        case .values(let values):
            return values.firstIndex(of: value)
        case .range(let range):
            return range.contains(value) ? value - range.lowerBound : nil
        }
    }
}

// MARK: - PickerColumnsState
struct PickerColumnsState: Equatable {
    var rows: [PickerColumnRows]
    var selectedRows: [Int]

    static let empty = PickerColumnsState(rows: [], selectedRows: [])

    init(rows: [PickerColumnRows], selectedRows: [Int]) {
        self.rows = rows
        self.selectedRows = selectedRows
    }

    init(rows: [PickerColumnRows], selectedValues: [Int]) {
        self.rows = rows
        self.selectedRows = zip(rows, selectedValues).map { $0.row(of: $1) ?? 0 }
    }

    /// 행 목록 또는 선택 행이 바뀐 컬럼
    func changedComponents(from old: PickerColumnsState) -> [Int] {
        return rows.indices.filter {
            rows[$0] != old.rows[safe: $0] || selectedRows[$0] != old.selectedRows[safe: $0]
        }
    }
}

// MARK: - PickerMinuteWindow
/// 기준일 0시부터 지난 분 기준 선택 가능 범위 + 간격
struct PickerMinuteWindow {
    static let minutesPerDay = 24 * 60

    let lowerBound: Int
    let upperBound: Int
    let step: Int

    init(lowerBound: Int, upperBound: Int, step: Int) {
        self.lowerBound = lowerBound
        self.upperBound = max(lowerBound, upperBound)
        self.step = max(1, step)
    }

    /// 범위 안에 간격에 맞는 값이 없으면 lowerBound 하나만 허용
    private var hasStepAlignedValue: Bool {
        return ceilToStep(lowerBound) <= upperBound
    }

    /// clamp → 내림 → 내림 결과 < lowerBound면 올림
    func normalize(_ minutes: Int) -> Int {
        guard hasStepAlignedValue else { return lowerBound }
        let clamped = min(max(minutes, lowerBound), upperBound)
        let floored = clamped / step * step
        return floored < lowerBound ? floored + step : floored
    }

    /// 선택 가능한 분이 있는 시(0~24)
    var hours: [Int] {
        return (lowerBound / 60...upperBound / 60).filter { !minutes(inHour: $0).isEmpty }
    }

    /// 해당 시에서 선택 가능한 분(0~59)
    func minutes(inHour hour: Int) -> [Int] {
        let hourStart = hour * 60
        guard hasStepAlignedValue else {
            return hour == lowerBound / 60 ? [lowerBound - hourStart] : []
        }
        let first = ceilToStep(max(lowerBound, hourStart))
        let last = min(upperBound, hourStart + 59)
        guard first <= last else { return [] }
        return stride(from: first, through: last, by: step).map { $0 - hourStart }
    }

    private func ceilToStep(_ minutes: Int) -> Int {
        return (minutes + step - 1) / step * step
    }
}

// MARK: - PickerTimeOfDay
/// time 모드 값: 기준일 + 기준일 0시부터 지난 분.
/// min/max는 각 값의 시·분만 사용한다. 상한 24:00은 max가 min 기준일 다음날 00:00일 때만 인정
struct PickerTimeOfDay {
    private let step: Int
    private let allowsEndOfDay: Bool
    private(set) var window: PickerMinuteWindow
    private(set) var anchorDay: Date
    private(set) var minutes: Int = 0

    var date: Date {
        return PickerDateMath.date(byAddingMinutes: minutes, to: anchorDay)
    }

    init(minimumDate: Date?, maximumDate: Date?, step: Int, allowsEndOfDay: Bool, initialDate: Date) {
        self.step = step
        self.allowsEndOfDay = allowsEndOfDay
        self.window = PickerTimeOfDay.makeWindow(
            minimumDate: minimumDate,
            maximumDate: maximumDate,
            step: step,
            allowsEndOfDay: allowsEndOfDay
        )
        self.anchorDay = PickerDateMath.calendar.startOfDay(for: initialDate)
        setDate(initialDate)
    }

    /// 받은 날짜의 날 유지. 현재 기준일 다음날 00:00이고 24:00 허용 범위면 기준일 24:00
    mutating func setDate(_ date: Date) {
        let calendar = PickerDateMath.calendar
        let day = calendar.startOfDay(for: date)
        let minutes = PickerDateMath.minutes(of: date, since: day)
        if minutes == 0,
           window.upperBound == PickerMinuteWindow.minutesPerDay,
           calendar.date(byAdding: .day, value: 1, to: anchorDay) == day {
            self.minutes = window.normalize(PickerMinuteWindow.minutesPerDay)
        } else {
            anchorDay = day
            self.minutes = window.normalize(minutes)
        }
    }

    mutating func setRange(minimum: Date?, maximum: Date?) {
        window = PickerTimeOfDay.makeWindow(
            minimumDate: minimum,
            maximumDate: maximum,
            step: step,
            allowsEndOfDay: allowsEndOfDay
        )
        minutes = window.normalize(minutes)
    }

    mutating func setMinutes(_ minutes: Int) {
        self.minutes = window.normalize(minutes)
    }

    private static func makeWindow(
        minimumDate: Date?,
        maximumDate: Date?,
        step: Int,
        allowsEndOfDay: Bool
    ) -> PickerMinuteWindow {
        let calendar = PickerDateMath.calendar
        let lastMinuteOfDay = PickerMinuteWindow.minutesPerDay - 1
        let lower = minimumDate.map { PickerDateMath.minutes(of: $0, since: calendar.startOfDay(for: $0)) } ?? 0
        let upper: Int
        if let maximumDate {
            let maximumDay = calendar.startOfDay(for: maximumDate)
            let maximumMinutes = PickerDateMath.minutes(of: maximumDate, since: maximumDay)
            let isEndOfMinimumDay = minimumDate
                .flatMap { calendar.date(byAdding: .day, value: 1, to: calendar.startOfDay(for: $0)) } == maximumDay
            // min 기준일 다음날 00:00 = 24:00. 12시간제는 아래에서 23:59로 제한
            upper = maximumMinutes == 0 && isEndOfMinimumDay
                ? PickerMinuteWindow.minutesPerDay
                : maximumMinutes
        } else {
            upper = lastMinuteOfDay
        }
        return PickerMinuteWindow(
            lowerBound: min(max(lower, 0), lastMinuteOfDay),
            upperBound: min(max(upper, 0), allowsEndOfDay ? PickerMinuteWindow.minutesPerDay : lastMinuteOfDay),
            step: step
        )
    }
}

// MARK: - PickerDateMath
enum PickerDateMath {
    static let calendar = Calendar.koin

    /// min/max 미지정 시 기본 범위
    static let defaultMinimumDate: Date = calendar.date(from: DateComponents(year: 1900, month: 1, day: 1)) ?? .distantPast
    static let defaultMaximumDate: Date = calendar.date(from: DateComponents(year: 2100, month: 12, day: 31, hour: 23, minute: 59)) ?? .distantFuture

    /// 초·나노초 버림
    static func flooredToMinute(_ date: Date) -> Date {
        return Date(timeIntervalSinceReferenceDate: (date.timeIntervalSinceReferenceDate / 60).rounded(.down) * 60)
    }

    static func minutes(of date: Date, since dayStart: Date) -> Int {
        return Int((flooredToMinute(date).timeIntervalSince(dayStart) / 60).rounded(.down))
    }

    static func date(byAddingMinutes minutes: Int, to dayStart: Date) -> Date {
        return calendar.date(byAdding: .minute, value: minutes, to: dayStart) ?? dayStart
    }

    static func days(from startDay: Date, to endDay: Date) -> Int {
        return calendar.dateComponents([.day], from: startDay, to: endDay).day ?? 0
    }
}

// MARK: - Array
extension Array {
    fileprivate subscript(safe index: Int) -> Element? {
        return indices.contains(index) ? self[index] : nil
    }
}

// MARK: - PickerMeridiemSymbols
enum PickerMeridiemSymbols {
    /// 오전/오후
    case korean
    /// AM/PM
    case english
}

// MARK: - PickerTitle
enum PickerTitle {

    static func meridiem(isPM: Bool, symbols: PickerMeridiemSymbols) -> String {
        switch symbols {
        case .korean: return isPM ? KoinDateFormat.pmSymbol : KoinDateFormat.amSymbol
        case .english: return isPM ? "PM" : "AM"
        }
    }

    /// 0 → 12, 13 → 1
    static func hour12(_ hour: Int) -> String {
        let hour = hour % 12
        return String(hour == 0 ? 12 : hour)
    }

    static func hour24(_ hour: Int) -> String {
        return String(hour)
    }

    static func minute(_ minute: Int) -> String {
        return String(format: "%02d", minute)
    }
}
