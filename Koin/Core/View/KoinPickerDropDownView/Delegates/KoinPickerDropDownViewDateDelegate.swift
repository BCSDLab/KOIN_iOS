//
//  KoinPickerDropDownViewDateDelegate.swift
//  koin
//
//  Created by 홍기정 on 3/6/26.
//

import Foundation
import Then

final class KoinPickerDropDownViewDateDelegate {
    
    // MARK: - Properties
    private var dates: [Int: [Int: [Int]]] = [:]
    private let columnWidths: [CGFloat] = [53, 31, 31]
    
    // MARK: - Initialzier
    init(range: Range<Int>) {
        resetDates(range: range)
    }
}

extension KoinPickerDropDownViewDateDelegate: KoinPickerDropDownViewDelegate {
    
    func reset(koinPicker: KoinPickerDropDownView, initialDate: Date) {
        let year = initialDate.year
        let month = initialDate.month
        let day = initialDate.day
        
        let items = getItems(year: year, month: month)
        let selectedItem: [String] = ["\(year)년", "\(month)월", "\(day)일"]
        
        koinPicker.reset(items: items, selectedItem: selectedItem, columnWidths: columnWidths)
    }

    func selectedItemUpdated(koinPicker: KoinPickerDropDownView, selectedItem: [String]) {
        
        guard let selectedYear = Int(selectedItem[0].filter { $0.isNumber }),
              var selectedMonth = Int(selectedItem[1].filter { $0.isNumber }),
              var selectedDay = Int(selectedItem[2].filter { $0.isNumber }) else {
            assert(false)
            return
        }
        let items = getItems(year: selectedYear, month: selectedMonth)
        guard let minMonthString = items[1].first?.filter({ $0.isNumber}),
              let minMonth = Int(minMonthString),
              let maxMonthString = items[1].last?.filter({ $0.isNumber}),
              let maxMonth = Int(maxMonthString) else {
            assert(false)
            return
        }
        guard let minDayString = items[2].first?.filter({ $0.isNumber }),
              let minDay = Int(minDayString),
              let maxDayString = items[2].last?.filter({ $0.isNumber }),
              let maxDay = Int(maxDayString) else {
            assert(false)
            return
        }
        selectedMonth = min(max(selectedMonth, minMonth), maxMonth)
        selectedDay = min(max(selectedDay, minDay), maxDay)
        let selectedItem: [String] = ["\(selectedYear)년", "\(selectedMonth)월", "\(selectedDay)일"]
        koinPicker.reset(items: items, selectedItem: selectedItem, columnWidths: columnWidths)
    }
}

extension KoinPickerDropDownViewDateDelegate {
    
    private func resetDates(range: Range<Int>) {
        let calendar = Calendar.current
        let startDay = calendar.startOfDay(for: Date())
        let availableDates = range.compactMap {
            calendar.date(byAdding: .day, value: $0, to: startDay)
        }
        
        var dates: [Int: [Int: [Int]]] = [:]
        
        for date in availableDates {
            if dates[date.year] == nil {
                dates[date.year] = [:]
            }

            if dates[date.year]?[date.month] == nil {
                dates[date.year]?[date.month] = []
            }

            dates[date.year]?[date.month]?.append(date.day)
        }
        
        self.dates = dates
    }
    
    private func getItems(year: Int, month: Int) -> [[String]] {
        guard let minYear: Int = dates.keys.sorted().first,
              let maxYear: Int = dates.keys.sorted().last else {
            assert(false)
            return [[],[],[]]
        }
        let year = min(max(minYear, year), maxYear)
        
        guard let minMonth: Int = dates[year]?.keys.sorted().first,
              let maxMonth: Int = dates[year]?.keys.sorted().last else {
            assert(false)
            return [[],[],[]]
        }
        let month = min(max(minMonth, month), maxMonth)
        
        let years: [String] = dates.keys.sorted().map { "\($0)년" }
        let months: [String] = dates[year]!.keys.sorted().map { "\($0)월" }
        let days: [String] = dates[year]![month]!.sorted().compactMap { "\($0)일" }
        return [years, months, days]
    }
}
