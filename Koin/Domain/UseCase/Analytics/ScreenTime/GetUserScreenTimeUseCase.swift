//
//  GetUserScreenTimeUseCase.swift
//  koin
//
//  Created by JOOMINKYUNG on 8/8/24.
//

import Combine
import Foundation

protocol GetUserScreenTimeUseCase {
    func returnUserScreenTime(isEventTime: Bool) -> TimeInterval
    func getUserScreenAction(time: Date, screenActionType: ScreenActionType, screenEventLabel: EventParameter.EventLabelNeededDuration?)
}

final class DefaultGetUserScreenTimeUseCase: GetUserScreenTimeUseCase {
    private var enterVcTime: Date = Date()
    private var beginEventTimes: [EventParameter.EventLabelNeededDuration: Date] = [:]
    private var enterBackgroundTime: Date?
    private var timeInBackground: TimeInterval = 0
    private var timeInBackgroundForEvent: TimeInterval = 0
    private var screenTime: TimeInterval = 0
    private var eventTime: TimeInterval = 0
    
    func returnUserScreenTime(isEventTime: Bool) -> TimeInterval {
        if isEventTime {
            return eventTime
        }
        return screenTime
    }
    
    func getUserScreenAction(time: Date, screenActionType: ScreenActionType, screenEventLabel: EventParameter.EventLabelNeededDuration?) {
        switch screenActionType {
        case .enterBackground:
            enterBackgroundTime = time
        case .enterForeground:
            if let enterBackgroundTime = enterBackgroundTime {
                timeInBackground += time.timeIntervalSince(enterBackgroundTime)
                timeInBackgroundForEvent += time.timeIntervalSince(enterBackgroundTime)
            }
        case .enterVC:
            self.enterVcTime = time
            timeInBackground = 0
            timeInBackgroundForEvent = 0
        case .beginEvent:
            if let screenEventLabel = screenEventLabel {
                beginEventTimes.updateValue(time, forKey: screenEventLabel)
            }
        case .leaveVC:
            let allScreenTime = time.timeIntervalSince(enterVcTime)
            screenTime = allScreenTime - timeInBackground
        case .endEvent:
            if let screenEventLabel = screenEventLabel,
               let beginEventTime = beginEventTimes[screenEventLabel] {
                let allEventTime = time.timeIntervalSince(beginEventTime)
                let tempTimeInBackgroundForEvent = timeInBackgroundForEvent
                timeInBackgroundForEvent = 0
                eventTime = allEventTime - tempTimeInBackgroundForEvent
            }
        }
    }
}

