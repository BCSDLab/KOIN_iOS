//
//  DiningDateRowConfiguration.swift
//  koin
//
//  Created by 홍기정 on 10/8/26.
//

import Foundation

struct DiningDateRowConfiguration {
    enum Style {
        case today
        case past
        case future
    }
    enum IndicatorStyle {
        case fill
        case border
        case none
    }
    
    let date: Date
    let style: Style
    let isSelected: Bool
    
    var font: FontAsset {
        .pretendardMedium
    }
    var fontSize: Int {
        isSelected ? 15 : 16
    }
    var textColor: ColorAsset {
        switch (style, isSelected) {
        case (_, true):
            return .neutral0
        case (.past, false):
            return .neutral500
        case (.today, false):
            return .new500
        case (.future, false):
            return .neutral800
        }
    }
    var indicatorColor: ColorAsset {
        switch (style, isSelected) {
        case (_, true), (.today, false):
            return .new500
        default:
            return .neutral0
        }
    }
    var indicatorStyle: IndicatorStyle {
        switch (style, isSelected) {
        case (_, true):
            return .fill
        case (.today, false):
            return .border
        default:
            return .none
        }
    }
}

extension DiningDateRowConfiguration {
    init(
        from date: Date,
        selectedDate: Date
    ) {
        self.date = date
        self.isSelected = Calendar.current.isDate(selectedDate, inSameDayAs: date)
        
        if date.weekday == Date().weekday {
            style = .today
        } else if date < Date() {
            style = .past
        } else {
            style = .future
        }
    }
}

extension DiningDateRowConfiguration: Identifiable, Equatable {
    var id: Date {
        date
    }
}
