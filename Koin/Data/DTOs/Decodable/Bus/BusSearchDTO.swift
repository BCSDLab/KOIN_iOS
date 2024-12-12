//
//  BusSearchDTO.swift
//  koin
//
//  Created by JOOMINKYUNG on 2024/04/03.
//. nullable 주민경 20204/05/02

import Foundation

// MARK: - Welcome
struct BusSearchDTO: Decodable {
    let depart: BusPlace
    let arrival: BusPlace
    let departDate, departTime: String
    let schedule: [Schedule]

    enum CodingKeys: String, CodingKey {
        case depart, arrival
        case departDate = "depart_date"
        case departTime = "depart_time"
        case schedule
    }
}

// MARK: - Schedule
struct Schedule: Decodable {
    let busType: BusType
    let busName, departTime: String

    enum CodingKeys: String, CodingKey {
        case busType = "bus_type"
        case busName = "bus_name"
        case departTime = "depart_time"
    }
}

extension BusSearchDTO {
    func toDomain() -> SearchBusInfoResult {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        let date = Date().stringToDate(dateValue: departDate, dateFormatter: dateFormatter) ?? Date()
        let timeFormater = DateFormatter()
        timeFormater.dateFormat = "HH:mm:ss"
        let time = Date().stringToDate(dateValue: departTime, dateFormatter: dateFormatter) ?? Date()
        let domainSchedule = schedule.map { $0.toDomain(date: departDate) }
        return SearchBusInfoResult(depart: depart, arrival: arrival, departDate: date, departTime: time, schedule: domainSchedule)
    }
}

extension Schedule {
    func toDomain(date: String) -> ScheduleInformation {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        let date = Date().stringToDate(dateValue: "\(date) \(departTime)", dateFormatter: dateFormatter) ?? Date()
        let timeInterval = date.timeIntervalSinceNow
        return ScheduleInformation(busType: busType, departTime: date, remainTime: timeInterval)
    }
}
