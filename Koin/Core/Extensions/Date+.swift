//
//  Date+.swift
//  koin
//
//  Created by 김나훈 on 6/9/24.
//

import Foundation

extension Date {
    func isWeekend() -> Bool {
        let calendar = Calendar.current
        let components = calendar.dateComponents([.weekday], from: self)
        if let weekday = components.weekday {
            return weekday == 1 || weekday == 7
        }
        return false
    }
    
    func formatDateToYYMMDD() -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyMMdd"
        return dateFormatter.string(from: self)
    }
    
    func formatDateToHHMM(isHH: Bool) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.locale = Locale(identifier: "ko_KR")
        
        if isHH {
            dateFormatter.dateFormat = "HH:mm"
        }
        else {
            dateFormatter.dateFormat = "a hh:mm"
        }
        return dateFormatter.string(from: self)
    }
    
    func formatDateToMMDDE() -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.locale = Locale(identifier: "ko_KR")
        dateFormatter.dateFormat = "MM.dd E"
        return dateFormatter.string(from: self)
    }
    
    func formatDateToMDE() -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.locale = Locale(identifier: "ko_KR")
        dateFormatter.dateFormat = "M월 d일 E요일"
        return dateFormatter.string(from: self)
    }
    
    func formatDateToYYYYMMDD(separator: Character) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.locale = Locale(identifier: "ko_KR")
        dateFormatter.dateFormat = "yyyy\(separator)MM\(separator)dd"
        return dateFormatter.string(from: self)
    }
    
    func dayOfWeek() -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.locale = Locale(identifier: "ko_KR")
        dateFormatter.dateFormat = "EEE"
        return dateFormatter.string(from: self)
    }
    
    func dayOfMonth() -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "d"
        return dateFormatter.string(from: self)
    }
    
    func formatDateToCustom() -> String {
          let dateFormatter = DateFormatter()
          dateFormatter.dateFormat = "yyyy.MM.dd '업데이트'"
          return dateFormatter.string(from: self)
      }
}
