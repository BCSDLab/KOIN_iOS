//
//  FetchKoinPickerDateUseCase.swift
//  koin
//
//  Created by JOOMINKYUNG on 12/9/24.
//

import Foundation

protocol FetchKoinPickerDataUseCase {
    func execute() -> ([[String]], [String])
}

final class DefaultFetchKoinPickerDataUseCase: FetchKoinPickerDataUseCase {
    func execute() -> ([[String]], [String]) {
        let formatter = DateFormatter()
        formatter.dateFormat = "M월 d일(EEE)"
        formatter.locale = Locale(identifier: "ko_KR")
        
        let sequence = Array(2..<90)
        let dateArray = Date().generateDateArray(formatter: formatter, sequence: sequence)
        let amPmArray = ["오전", "오후"]
        let calendar = Calendar.current
        let currentDate = Date()
        let currentHour = calendar.component(.hour, from: currentDate)
        let currentMinute = calendar.component(.minute, from: currentDate)
        let hourArray: [String] = Array(0..<12).map { String($0) }
        let minuteArray: [String] = Array(0..<60).map { String(format: "%02d", $0) }
      
        let amPmIndex = currentHour < 12 ? 0 : 1
        let selectedAmPm = amPmArray[amPmIndex]
      
        let adjustedHour = currentHour % 12
        let selectedHour = String(adjustedHour == 0 ? 12 : adjustedHour)
        
        let selectedMinute = String(format: "%02d", currentMinute)
       
        let selectedItems = [dateArray[0], selectedAmPm, selectedHour, selectedMinute]
        
        return ([dateArray, amPmArray, hourArray, minuteArray], selectedItems)
    }
}
