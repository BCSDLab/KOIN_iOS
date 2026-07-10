//
//  NotificationHistoryError.swift
//  koin
//
//  Created by 홍기정 on 7/7/26.
//

import Foundation

struct NotificationHistoryError: LocalizedError {
    let errorDescription: String
    
    static let calendarDidFail = Self.init(errorDescription: "캘린더 오류 발생")
}
