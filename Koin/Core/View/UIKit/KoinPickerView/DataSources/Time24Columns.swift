//
//  Time24Columns.swift
//  koin
//
//  Created by 홍기정 on 10/30/26.
//

import Foundation

/// H · mm. 시 = 기준일 0시부터 지난 분 / 60 → 24:00 지원(시=24이면 분 00만)
final class Time24Columns: PickerColumnsDataSource {

    private enum Component: Int {
        case hour, minute
    }

    // MARK: - Properties
    private var timeOfDay: PickerTimeOfDay
    private(set) var columnsState: PickerColumnsState = .empty

    var date: Date {
        return timeOfDay.date
    }

    // MARK: - Initializer
    init(minimumDate: Date?, maximumDate: Date?, minuteInterval: Int, initialDate: Date) {
        timeOfDay = PickerTimeOfDay(
            minimumDate: minimumDate,
            maximumDate: maximumDate,
            step: minuteInterval,
            allowsEndOfDay: true,
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
        case .hour: return PickerTitle.hour24(value)
        case .minute: return PickerTitle.minute(value)
        }
    }

    func widthTemplates(inComponent component: Int) -> [String] {
        switch Component(rawValue: component) {
        case .hour: return [PickerTitle.hour24(24)]
        case .minute: return [PickerTitle.minute(0)]
        case .none: return []
        }
    }
}

extension Time24Columns {

    private func makeColumnsState() -> PickerColumnsState {
        let window = timeOfDay.window
        let hour = timeOfDay.minutes / 60
        return PickerColumnsState(
            rows: [
                .values(window.hours),
                .values(window.minutes(inHour: hour))
            ],
            selectedValues: [hour, timeOfDay.minutes % 60]
        )
    }
}
