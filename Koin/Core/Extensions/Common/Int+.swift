//
//  Int+.swift
//  koin
//
//  Created by 김나훈 on 4/11/24.
//

import Foundation

extension Int {
    var formattedWithComma: String {
        let numberFormatter = NumberFormatter()
        numberFormatter.numberStyle = .decimal
        numberFormatter.groupingSeparator = ","
        numberFormatter.maximumFractionDigits = 0 
        return numberFormatter.string(from: NSNumber(value: self)) ?? "\(self)"
    }
}
