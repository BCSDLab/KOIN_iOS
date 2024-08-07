//
//  BusTimeTableDTO.swift
//  koin
//
//  Created by JOOMINKYUNG on 2024/04/03.
// nullable 주민경

import Foundation

struct ShuttleBusTimetableDTO: Decodable {
    let busTimetables: [ShuttleBusTimetable]?
    let updatedAt: String?

    enum CodingKeys: String, CodingKey {
        case busTimetables = "bus_timetables"
        case updatedAt = "updated_at"
    }
}

// MARK: - BusTimetable
struct ShuttleBusTimetable: Decodable {
    let routeName: String
    let arrivalInfo: [ArrivalInfo]

    enum CodingKeys: String, CodingKey {
        case routeName = "route_name"
        case arrivalInfo = "arrival_info"
    }
}

// MARK: - ArrivalInfo
struct ArrivalInfo: Decodable {
    let nodeName, arrivalTime: String
    enum CodingKeys: String, CodingKey {
        case nodeName = "node_name"
        case arrivalTime = "arrival_time"
    }
}

// MARK: - BusTimetable
struct ExpressTimetable: Decodable {
    let departure, arrival: String
    let charge: Int
}

struct ExpressTimetableDTO: Decodable {
    let expressTimeTable: [ExpressTimetable]?
    let updatedAt: String?
    
    enum CodingKeys: String, CodingKey {
        case expressTimeTable = "bus_timetables"
        case updatedAt = "updated_at"
    }
    
}

extension ShuttleBusTimetable {
    func toDomain() -> [BusArrivalInfo] {
        var newArrivalInfos: [BusArrivalInfo] = []
        for arrivalInfo in self.arrivalInfo {
            newArrivalInfos.append(BusArrivalInfo(leftNode: arrivalInfo.nodeName, rightNode: arrivalInfo.arrivalTime))
        }
        return newArrivalInfos
    }
}

extension ShuttleBusTimetableDTO {
    func toDomain() -> [BusTimetableInfo] {
        var updatedAtText: String = ""
        var busTimetableInfos: [BusTimetableInfo] = []
        
        if let updatedAt = updatedAt {
            let updatedComponents = updatedAt.components(separatedBy: " ")
            updatedAtText = updatedComponents.first ?? ""
        }
        
        if let busTimetables = self.busTimetables {
            for busTimetable in busTimetables {
                let busTimetableInfo = BusTimetableInfo(courseName: "", routeName: busTimetable.routeName, arrivalInfos: busTimetable.toDomain(), updatedAt: updatedAtText)
                busTimetableInfos.append(busTimetableInfo)
            }
        }
        return busTimetableInfos
    }
}

extension ExpressTimetableDTO {
    func toDomain() -> BusTimetableInfo {
        var updatedAtText: String = ""
        var arrivalInfos: [BusArrivalInfo] = []
        if let updatedAt = updatedAt {
            let updatedComponents = updatedAt.components(separatedBy: " ")
            updatedAtText = updatedComponents.first ?? ""
        }
        if let expressTimeTable = expressTimeTable {
            for timetable in expressTimeTable {
                let arrivalInfo: BusArrivalInfo = BusArrivalInfo(leftNode: timetable.departure, rightNode: timetable.arrival)
                arrivalInfos.append(arrivalInfo)
            }
        }
        let timetableinfo = BusTimetableInfo(courseName: "", routeName: "", arrivalInfos: arrivalInfos, updatedAt: updatedAtText)
        return timetableinfo
    }
}
