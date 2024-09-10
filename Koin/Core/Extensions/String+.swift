//
//  String+.swift
//  koin
//
//  Created by 김나훈 on 4/9/24.
//

import Foundation

extension String {
    func hasFinalConsonant() -> Bool {
        guard let lastText = self.last else { return false }
        let unicodeVal = UnicodeScalar(String(lastText))?.value
        
        guard let value = unicodeVal else { return false }
        if (value < 0xAC00 || value > 0xD7A3) { return false }
        let last = (value - 0xAC00) % 28
        return last > 0
    }
    
    func toDateFromYYMMDD() -> Date? {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyMMdd"
        return dateFormatter.date(from: self)
    }
    
    func toDateFromYYYYMMDD() -> Date? {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        return dateFormatter.date(from: self)
    }
}
