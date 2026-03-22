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
    let columnWidths: [CGFloat] = [53, 31, 31]
    
    private let inputFormatter = DateFormatter().then {
        $0.dateFormat = "yyyy-MM-dd"
    }
    
    private let outputFormatter = DateFormatter().then {
        $0.dateFormat = "yyyy년*M월*d일"
    }
}

extension KoinPickerDropDownViewDateDelegate: KoinPickerDropDownViewDelegate {
    
    func reset(koinPicker: KoinPickerDropDownView, initialDate: Date) {
        
        let selectedItem = outputFormatter.string(from: initialDate).components(separatedBy: "*")
        let items = getItems(selectedItem: selectedItem)
        
        koinPicker.reset(items: items, selectedItem: selectedItem, columnWidths: [53, 31, 31])
    }

    func selectedItemUpdated(koinPicker: KoinPickerDropDownView, selectedItem: [String]) {
        
        guard let yearInt = Int(selectedItem[0].filter { $0.isNumber }),
              let monthInt = Int(selectedItem[1].filter { $0.isNumber }),
              var dayInt = Int(selectedItem[2].filter { $0.isNumber }) else {
            assert(false)
            return
        }
        let maxDay = getAllDays(year: yearInt, month: monthInt).count
        if dayInt > maxDay {
            dayInt = maxDay
        }
        guard let validDate = inputFormatter.date(from: String(format: "%d-%d-%d", yearInt, monthInt, dayInt)) else {
            assert(false)
            return
        }
        reset(koinPicker: koinPicker, initialDate: validDate)
    }
}

extension KoinPickerDropDownViewDateDelegate {
    
    private func getItems(selectedItem: [String]) -> [[String]] {
        
        guard let selectedYearInt = Int(selectedItem[0].filter { $0.isNumber }),
              let selectedMonthInt = Int(selectedItem[1].filter { $0.isNumber }) else {
            assert(false)
            return [[],[],[]]
        }
        
        let years: [String] = {
            let thisYearInt = Date().year
            let lowestYearInt = min(selectedYearInt, thisYearInt)
            let heighestYearInt = thisYearInt + 1
            return Range(lowestYearInt...heighestYearInt).map { String($0)+"년" }
        }()
        let months: [String] = Range(1...12).map { String($0)+"월" }
        let days: [String] = getAllDays(year: selectedYearInt, month: selectedMonthInt)
        
        return [years, months, days]
    }
    
    func getAllDays(year: Int, month: Int) -> [String] {
        
        let calendar = Calendar.current
        var components = DateComponents()
        components.year = year
        components.month = month
        
        guard let date = calendar.date(from: components),
              let dayRange = calendar.range(of: .day, in: .month, for: date) else {
            assert(false)
            return []
        }
        
        return dayRange.map { String($0) + "일" }
    }
}
