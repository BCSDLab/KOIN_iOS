//
//  TimeInterval+.swift
//  koin
//
//  Created by JOOMINKYUNG on 12/10/24.
//

import Foundation

extension TimeInterval {
    func timeDifference() -> (hours: Int?, minutes: Int) {
        let absoluteInterval = abs(self)
        let hours = Int(absoluteInterval) / 3600
        let minutes = (Int(absoluteInterval) % 3600) / 60
        
        if hours == 0 { return (nil, minutes) }
        
        return (hours, minutes)
    }
}
