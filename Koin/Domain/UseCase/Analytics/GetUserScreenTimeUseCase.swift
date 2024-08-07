//
//  GetUserScreenTimeUseCase.swift
//  koin
//
//  Created by JOOMINKYUNG on 8/8/24.
//

import Foundation

protocol GetUserScreenTimeUseCase {
    func enterVc(enterVcTime: Date)
    func enterBackground(enterBackgroundTime: Date)
    func backForeground(backForegroundTime: Date)
    func leaveVc(leaveVcTime: Date) -> String
    func beginEvent(beginEventTime: Date, eventLabel: EventParameter.EventLabelNeededDuration)
    func endEvent(endEventTime: Date, eventLabel: EventParameter.EventLabelNeededDuration) -> String
}

final class DefaultGetUserScreenTimeUseCase: GetUserScreenTimeUseCase {
    private var enterVcTime: Date = Date()
    private var beginEventTimes: [EventParameter.EventLabelNeededDuration: Date] = [:]
    private var enterBackgroundTime: Date?
    private var timeInBackground: TimeInterval = 0
    private var timeInBackgroundForEvent: TimeInterval = 0
    
    func enterVc(enterVcTime: Date) {
        self.enterVcTime = enterVcTime
    }
    
    func enterBackground(enterBackgroundTime: Date) {
        self.enterBackgroundTime = enterBackgroundTime
    }
    
    func backForeground(backForegroundTime: Date) {
        if let enterBackgroundTime = enterBackgroundTime {
            self.timeInBackground += backForegroundTime.timeIntervalSince(enterBackgroundTime)
        }
    }
    
    func leaveVc(leaveVcTime: Date) -> String {
        let allTimeInScreen = leaveVcTime.timeIntervalSince(enterVcTime)
        let finalForegroundTime = (allTimeInScreen - timeInBackground)
        return "\(finalForegroundTime)"
    }
    
    func beginEvent(beginEventTime: Date, eventLabel: EventParameter.EventLabelNeededDuration) {
        self.beginEventTimes[eventLabel] = beginEventTime
    }
    
    func endEvent(endEventTime: Date, eventLabel: EventParameter.EventLabelNeededDuration) -> String {
        if let beginBusinessEventTime = beginEventTimes[eventLabel] {
            let allEventTime = endEventTime.timeIntervalSince(beginBusinessEventTime)
            return "\(allEventTime - timeInBackground)"
        }
        timeInBackgroundForEvent = 0
        return ""
    }
}

