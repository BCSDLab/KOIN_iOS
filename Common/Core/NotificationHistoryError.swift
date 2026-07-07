//
//  NotificationHistoryError.swift
//  koin
//
//  Created by 홍기정 on 7/7/26.
//

import Foundation

struct NotificationHistoryError: Error {
    let message: String
    
    static let calendarDidFail = Self.init(message: "캘린더 오류 발생")
}
