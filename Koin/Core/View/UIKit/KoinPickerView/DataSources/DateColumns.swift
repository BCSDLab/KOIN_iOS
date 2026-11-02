//
//  DateColumns.swift
//  koin
//
//  Created by 홍기정 on 10/30/26.
//

import Foundation

/// yyyy년 · M월 · d일. 값은 그날 00:00
final class DateColumns: PickerColumnsDataSource {

    private enum Component: Int {
        case year, month, day
    }

    private struct YearMonthDay: Equatable {
        var year: Int
        var month: Int
        var day: Int
    }

    // MARK: - Properties
    private let calendar = PickerDateMath.calendar
    private var minimum: YearMonthDay
    private var maximum: YearMonthDay
    private var selected: YearMonthDay
    private(set) var columnsState: PickerColumnsState = .empty

    var date: Date {
        return makeDate(selected)
    }

    // MARK: - Initializer
    init(minimumDate: Date?, maximumDate: Date?, initialDate: Date) {
        self.minimum = YearMonthDay(year: 0, month: 0, day: 0)
        self.maximum = YearMonthDay(year: 0, month: 0, day: 0)
        self.selected = YearMonthDay(year: 0, month: 0, day: 0)
        applyRange(minimum: minimumDate, maximum: maximumDate)
        setDate(initialDate)
    }

    // MARK: - PickerColumnsDataSource
    func setDate(_ date: Date) {
        let day = min(max(calendar.startOfDay(for: date), makeDate(minimum)), makeDate(maximum))
        selected = yearMonthDay(of: day)
        columnsState = makeColumnsState()
    }

    func setRange(minimum: Date?, maximum: Date?) {
        let current = date
        applyRange(minimum: minimum, maximum: maximum)
        setDate(current)
    }

    func selectRow(_ row: Int, inComponent component: Int) -> [Int] {
        guard let column = Component(rawValue: component),
              let value = columnsState.rows[component].value(at: row) else {
            return []
        }
        var target = selected
        switch column {
        case .year: target.year = value
        case .month: target.month = value
        case .day: target.day = value
        }
        selected = normalized(target)

        let oldState = columnsState
        columnsState = makeColumnsState()
        return Array(Set(columnsState.changedComponents(from: oldState) + [component])).sorted()
    }

    func title(forRow row: Int, inComponent component: Int) -> String {
        guard let column = Component(rawValue: component),
              let value = columnsState.rows[component].value(at: row) else {
            return ""
        }
        switch column {
        case .year:
            return title(of: YearMonthDay(year: value, month: 1, day: 1), column: column)
        case .month:
            return title(of: YearMonthDay(year: selected.year, month: value, day: 1), column: column)
        case .day:
            return title(of: YearMonthDay(year: selected.year, month: selected.month, day: value), column: column)
        }
    }

    /// 연 4자리, 월·일 2자리 + 단위
    func widthTemplates(inComponent component: Int) -> [String] {
        guard let column = Component(rawValue: component) else { return [] }
        return [title(of: YearMonthDay(year: maximum.year, month: 12, day: 30), column: column)]
    }
}

extension DateColumns {

    private func applyRange(minimum minimumDate: Date?, maximum maximumDate: Date?) {
        let minimumDay = calendar.startOfDay(for: minimumDate ?? PickerDateMath.defaultMinimumDate)
        let maximumDay = max(minimumDay, calendar.startOfDay(for: maximumDate ?? PickerDateMath.defaultMaximumDate))
        minimum = yearMonthDay(of: minimumDay)
        maximum = yearMonthDay(of: maximumDay)
    }

    /// 연 → 월 → 일 순서로 범위 안으로 보정. 일 소멸 시 말일
    private func normalized(_ value: YearMonthDay) -> YearMonthDay {
        var value = value
        let years = yearRange()
        value.year = min(max(value.year, years.lowerBound), years.upperBound)
        let months = monthRange(year: value.year)
        value.month = min(max(value.month, months.lowerBound), months.upperBound)
        let days = dayRange(year: value.year, month: value.month)
        value.day = min(max(value.day, days.lowerBound), days.upperBound)
        return value
    }

    private func makeColumnsState() -> PickerColumnsState {
        return PickerColumnsState(
            rows: [
                .range(yearRange()),
                .range(monthRange(year: selected.year)),
                .range(dayRange(year: selected.year, month: selected.month))
            ],
            selectedValues: [selected.year, selected.month, selected.day]
        )
    }

    private func yearRange() -> ClosedRange<Int> {
        return minimum.year...maximum.year
    }

    private func monthRange(year: Int) -> ClosedRange<Int> {
        let lower = year == minimum.year ? minimum.month : 1
        let upper = year == maximum.year ? maximum.month : 12
        return lower...max(lower, upper)
    }

    private func dayRange(year: Int, month: Int) -> ClosedRange<Int> {
        let lower = (year, month) == (minimum.year, minimum.month) ? minimum.day : 1
        let upper = (year, month) == (maximum.year, maximum.month) ? maximum.day : numberOfDays(year: year, month: month)
        return lower...max(lower, upper)
    }

    private func numberOfDays(year: Int, month: Int) -> Int {
        let firstDay = makeDate(YearMonthDay(year: year, month: month, day: 1))
        return calendar.range(of: .day, in: .month, for: firstDay)?.count ?? 28
    }

    private func title(of value: YearMonthDay, column: Component) -> String {
        let date = makeDate(value)
        switch column {
        case .year: return date.string(with: .yearUnit)
        case .month: return date.string(with: .monthUnit)
        case .day: return date.string(with: .dayUnit)
        }
    }

    private func yearMonthDay(of date: Date) -> YearMonthDay {
        let components = calendar.dateComponents([.year, .month, .day], from: date)
        return YearMonthDay(year: components.year ?? 0, month: components.month ?? 1, day: components.day ?? 1)
    }

    private func makeDate(_ value: YearMonthDay) -> Date {
        let components = DateComponents(year: value.year, month: value.month, day: value.day)
        return calendar.date(from: components) ?? PickerDateMath.defaultMinimumDate
    }
}
