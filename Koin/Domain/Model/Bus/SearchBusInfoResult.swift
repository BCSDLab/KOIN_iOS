//
//  SearchBusInfoResult.swift
//  koin
//
//  Created by JOOMINKYUNG on 7/26/24.
//

import Foundation

struct SearchBusInfoResult {
    let depart: BusPlace
    let arrival: BusPlace
    let departDate: Date
    let departTime: Date
    let schedule: Array<ScheduleInformation>
}

struct ScheduleInformation {
    let busType: BusType
    let departTime: Date
    let remainTime: TimeInterval
}
