//
//  BusTimeTableDTO.swift
//  koin
//
//  Created by JOOMINKYUNG on 2024/04/03.
// nullable 주민경

import Foundation

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
        let timetableinfo = BusTimetableInfo(arrivalInfos: arrivalInfos, updatedAt: updatedAtText)
        return timetableinfo
    }
}
