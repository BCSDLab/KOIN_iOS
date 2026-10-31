//
//  Time12Columns.swift
//  koin
//
//  Created by 홍기정 on 10/30/26.
//

import Foundation

/// 오전/오후 · h · mm
final class Time12Columns: PickerColumnsDataSource {

    private enum Component: Int {
        case meridiem, hour, minute
    }

    // MARK: - Properties
    private let meridiemSymbols: PickerMeridiemSymbols
    private var timeOfDay: PickerTimeOfDay
    private(set) var columnsState: PickerColumnsState = .empty

    var date: Date {
        return timeOfDay.date
    }

    // MARK: - Initializer
    init(
        minimumDate: Date?,
        maximumDate: Date?,
        minuteInterval: Int,
        meridiemSymbols: PickerMeridiemSymbols,
        initialDate: Date
    ) {
        self.meridiemSymbols = meridiemSymbols
        timeOfDay = PickerTimeOfDay(
            minimumDate: minimumDate,
            maximumDate: maximumDate,
            step: minuteInterval,
            allowsEndOfDay: false,
            initialDate: initialDate
        )
        columnsState = makeColumnsState()
    }

    // MARK: - PickerColumnsDataSource
    func setDate(_ date: Date) {
        timeOfDay.setDate(date)
        columnsState = makeColumnsState()
    }

    func setRange(minimum: Date?, maximum: Date?) {
        timeOfDay.setRange(minimum: minimum, maximum: maximum)
        columnsState = makeColumnsState()
    }

    func selectRow(_ row: Int, inComponent component: Int) -> [Int] {
        guard let column = Component(rawValue: component),
              let value = columnsState.rows[component].value(at: row) else {
            return []
        }
        let hour = timeOfDay.minutes / 60
        let minute = timeOfDay.minutes % 60
        switch column {
        case .meridiem: timeOfDay.setMinutes((value * 12 + hour % 12) * 60 + minute)
        case .hour: timeOfDay.setMinutes(value * 60 + minute)
        case .minute: timeOfDay.setMinutes(hour * 60 + value)
        }

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
        case .meridiem: return PickerTitle.meridiem(isPM: value == 1, symbols: meridiemSymbols)
        case .hour: return PickerTitle.hour12(value)
        case .minute: return PickerTitle.minute(value)
        }
    }

    func widthTemplates(inComponent component: Int) -> [String] {
        switch Component(rawValue: component) {
        case .meridiem: return [false, true].map { PickerTitle.meridiem(isPM: $0, symbols: meridiemSymbols) }
        case .hour: return [PickerTitle.hour12(12)]
        case .minute: return [PickerTitle.minute(0)]
        case .none: return []
        }
    }
}

extension Time12Columns {

    /// 행 값: 오전 0 / 오후 1, 시 0~23, 분 0~59
    private func makeColumnsState() -> PickerColumnsState {
        let window = timeOfDay.window
        let hour = timeOfDay.minutes / 60
        let meridiem = hour / 12
        let hours = window.hours
        let meridiems = [0, 1].filter { candidate in hours.contains { $0 / 12 == candidate } }
        return PickerColumnsState(
            rows: [
                .values(meridiems),
                // 1 … 12 순서. 12시(0시·12시)가 마지막
                .values(hours.filter { $0 / 12 == meridiem }.sorted { ($0 + 11) % 12 < ($1 + 11) % 12 }),
                .values(window.minutes(inHour: hour))
            ],
            selectedValues: [meridiem, hour, timeOfDay.minutes % 60]
        )
    }
}
