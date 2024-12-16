//
//  BusSearchDTO.swift
//  koin
//
//  Created by JOOMINKYUNG on 2024/04/03.
//. nullable 주민경 20204/05/02

import Foundation

// MARK: - Welcome
struct BusSearchDTO: Decodable {
    let depart, arrival: BusPlace
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
    let routeName, departTime: String

    enum CodingKeys: String, CodingKey {
        case busType = "bus_type"
        case routeName = "route_name"
        case departTime = "depart_time"
    }
}

extension BusSearchDTO {
    func toDomain() -> SearchBusInfoResult {
        var dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        let date = Date().stringToDate(dateValue: departDate, dateFormatter: dateFormatter) ?? Date()
        let timeFormater = DateFormatter()
        timeFormater.dateFormat = "HH:mm"
        let time = Date().stringToDate(dateValue: departTime, dateFormatter: dateFormatter) ?? Date()
        let domainSchedule = schedule.map { $0.toDomain() }
        return SearchBusInfoResult(depart: depart, arrival: arrival, departDate: date, departTime: time, schedule: domainSchedule)
    }
}

extension Schedule {
    func toDomain() -> ScheduleInformation {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "HH:mm"
        let time = Date().stringToDate(dateValue: departTime, dateFormatter: dateFormatter) ?? Date()
        let timeInterval = time.timeIntervalSince(Date())
        return ScheduleInformation(busType: busType, departTime: time, remainTime: timeInterval)
    }
}
