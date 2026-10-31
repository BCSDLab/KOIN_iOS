//
//  DateAndTimeColumns.swift
//  koin
//
//  Created by 홍기정 on 10/30/26.
//

import Foundation

/// 날짜(오늘/내일/M월 d일(EEE)) · 오전/오후 · h · mm
final class DateAndTimeColumns: PickerColumnsDataSource {

    private enum Component: Int {
        case day, meridiem, hour, minute
    }

    // MARK: - Properties
    private let calendar = PickerDateMath.calendar
    private let step: Int
    private let relativeDayReference: Date?
    private let meridiemSymbols: PickerMeridiemSymbols
    private var minimumDate: Date
    private var maximumDate: Date
    /// minimumDate 날짜부터 지난 일수
    private var dayIndex: Int = 0
    /// 선택한 날짜 0시부터 지난 분
    private var minutes: Int = 0
    private(set) var columnsState: PickerColumnsState = .empty

    var date: Date {
        return PickerDateMath.date(byAddingMinutes: minutes, to: day(at: dayIndex))
    }

    // MARK: - Initializer
    init(
        minimumDate: Date?,
        maximumDate: Date?,
        minuteInterval: Int,
        relativeDayReference: Date?,
        meridiemSymbols: PickerMeridiemSymbols,
        initialDate: Date
    ) {
        self.step = minuteInterval
        self.relativeDayReference = relativeDayReference
        self.meridiemSymbols = meridiemSymbols
        self.minimumDate = PickerDateMath.defaultMinimumDate
        self.maximumDate = PickerDateMath.defaultMaximumDate
        applyRange(minimum: minimumDate, maximum: maximumDate)
        setDate(initialDate)
    }

    // MARK: - PickerColumnsDataSource
    func setDate(_ date: Date) {
        let clamped = min(max(PickerDateMath.flooredToMinute(date), minimumDate), maximumDate)
        let selectedDay = calendar.startOfDay(for: clamped)
        dayIndex = PickerDateMath.days(from: minimumDay, to: selectedDay)
        minutes = window(at: dayIndex).normalize(PickerDateMath.minutes(of: clamped, since: selectedDay))
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
        let hour = minutes / 60
        let minute = minutes % 60
        var target = minutes
        switch column {
        case .day: dayIndex = value
        case .meridiem: target = (value * 12 + hour % 12) * 60 + minute
        case .hour: target = value * 60 + minute
        case .minute: target = hour * 60 + value
        }
        minutes = window(at: dayIndex).normalize(target)

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
        case .day: return dayTitle(day(at: value))
        case .meridiem: return PickerTitle.meridiem(isPM: value == 1, symbols: meridiemSymbols)
        case .hour: return PickerTitle.hour12(value)
        case .minute: return PickerTitle.minute(value)
        }
    }

    /// 날짜: 2자리 월·일 요일 7종(2000-12-24 일 ~ 30 토) + 오늘·내일
    func widthTemplates(inComponent component: Int) -> [String] {
        switch Component(rawValue: component) {
        case .day:
            let weekDays = (24...30).compactMap { calendar.date(from: DateComponents(year: 2000, month: 12, day: $0)) }
            var templates = weekDays.map { $0.string(with: .monthDayWeekday) }
            if let relativeDayReference {
                let tomorrow = calendar.date(byAdding: .day, value: 1, to: relativeDayReference) ?? relativeDayReference
                templates += [relativeDayReference, tomorrow].map { $0.relativeDayString(today: relativeDayReference) }
            }
            return templates
        case .meridiem: return [false, true].map { PickerTitle.meridiem(isPM: $0, symbols: meridiemSymbols) }
        case .hour: return [PickerTitle.hour12(12)]
        case .minute: return [PickerTitle.minute(0)]
        case .none: return []
        }
    }
}

extension DateAndTimeColumns {

    private var minimumDay: Date {
        return calendar.startOfDay(for: minimumDate)
    }

    private var numberOfDays: Int {
        return PickerDateMath.days(from: minimumDay, to: calendar.startOfDay(for: maximumDate)) + 1
    }

    private func applyRange(minimum: Date?, maximum: Date?) {
        let minimumDate = PickerDateMath.flooredToMinute(minimum ?? PickerDateMath.defaultMinimumDate)
        let maximumDate = PickerDateMath.flooredToMinute(maximum ?? PickerDateMath.defaultMaximumDate)
        self.minimumDate = minimumDate
        self.maximumDate = max(minimumDate, maximumDate)
    }

    private func day(at index: Int) -> Date {
        return calendar.date(byAdding: .day, value: index, to: minimumDay) ?? minimumDay
    }

    /// 첫날은 minimumDate 시각부터, 마지막 날은 maximumDate 시각까지
    private func window(at index: Int) -> PickerMinuteWindow {
        let selectedDay = day(at: index)
        let lower = index == 0 ? PickerDateMath.minutes(of: minimumDate, since: selectedDay) : 0
        let upper = index == numberOfDays - 1
            ? PickerDateMath.minutes(of: maximumDate, since: selectedDay)
            : PickerMinuteWindow.minutesPerDay - 1
        return PickerMinuteWindow(lowerBound: lower, upperBound: upper, step: step)
    }

    private func dayTitle(_ day: Date) -> String {
        guard let relativeDayReference else {
            return day.string(with: .monthDayWeekday)
        }
        return day.relativeDayString(today: relativeDayReference)
    }

    /// 행 값: 날짜 index, 오전 0 / 오후 1, 시 0~23, 분 0~59
    private func makeColumnsState() -> PickerColumnsState {
        let window = window(at: dayIndex)
        let hour = minutes / 60
        let meridiem = hour / 12
        let hours = window.hours
        let meridiems = [0, 1].filter { candidate in hours.contains { $0 / 12 == candidate } }
        return PickerColumnsState(
            rows: [
                .range(0...max(0, numberOfDays - 1)),
                .values(meridiems),
                // 1 … 12 순서. 12시(0시·12시)가 마지막
                .values(hours.filter { $0 / 12 == meridiem }.sorted { ($0 + 11) % 12 < ($1 + 11) % 12 }),
                .values(window.minutes(inHour: hour))
            ],
            selectedValues: [dayIndex, meridiem, hour, minutes % 60]
        )
    }
}
