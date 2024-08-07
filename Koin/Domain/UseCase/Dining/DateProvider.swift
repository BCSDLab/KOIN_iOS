//
//  DateProvider.swift
//  koin
//
//  Created by 김나훈 on 6/9/24.
//

import Foundation

protocol DateProvider {
    func execute(date: Date) -> CurrentDiningTime
}

final class DefaultDateProvider: DateProvider {
    
    func execute(date: Date) -> CurrentDiningTime {
        let calendar = Calendar.current
        let hour = calendar.component(.hour, from: date)
        let minute = calendar.component(.minute, from: date)
        let currentTimeInMinutes = hour * 60 + minute
        
        let diningType: DiningType
        let adjustedDate: Date
        
        if currentTimeInMinutes < 9 * 60 {
            diningType = .breakfast
            adjustedDate = date
        } else if currentTimeInMinutes <= 13 * 60 + 30 {
            diningType = .lunch
            adjustedDate = date
        } else if currentTimeInMinutes <= 18 * 60 + 30 {
            diningType = .dinner
            adjustedDate = date
        } else {
            guard let nextDay = calendar.date(byAdding: .day, value: 1, to: date) else {
                return CurrentDiningTime(date: date, diningType: .breakfast)
            }
            diningType = .breakfast
            adjustedDate = nextDay
        }
        
        return CurrentDiningTime(date: adjustedDate, diningType: diningType)
    }
    
    private func formatDate(date: Date) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyMMdd"
        return dateFormatter.string(from: date)
    }
}
