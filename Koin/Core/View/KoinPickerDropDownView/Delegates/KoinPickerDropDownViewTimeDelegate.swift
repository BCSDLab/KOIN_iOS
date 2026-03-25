//
//  KoinPickerDropDownViewTimeDelegate.swift
//  koin
//
//  Created by 홍기정 on 3/6/26.
//

import Foundation
import Then

final class KoinPickerDropDownViewTimeDelegate {
    
    // MARK: - Properties
    private let inputFormatter = DateFormatter().then {
        $0.dateFormat = "HH:mm"
    }
    
    private let outputFormatter = DateFormatter().then {
        $0.locale = Locale(identifier: "en_US")
        $0.dateFormat = "a*h*mm"
    }
}

extension KoinPickerDropDownViewTimeDelegate: KoinPickerDropDownViewDelegate {
    
    func reset(koinPicker: KoinPickerDropDownView, initialDate: Date) {
        let dateString = outputFormatter.string(from: initialDate)
        let selectedItem = dateString.components(separatedBy: "*")
        koinPicker.reset(items: getItems(), selectedItem: selectedItem, columnWidths: [25, 18, 20])
    }

    func selectedItemUpdated(koinPicker: KoinPickerDropDownView, selectedItem: [String]) {
        koinPicker.update(selectedItem: selectedItem)
    }
}

extension KoinPickerDropDownViewTimeDelegate {
    
    private func getItems() -> [[String]] {
        
        let amPm = ["AM", "PM"]
        let hours = Array(1...12).map { "\($0)" }
        let minutes = Array(00...59).map { String(format: "%02d", $0) }
        
        return [amPm, hours, minutes]
    }
}
