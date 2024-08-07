//
//  BusCourseDTO.swift
//  koin
//
//  Created by JOOMINKYUNG on 2024/04/07.
//  nullable 주민경 2024/05/02

import Foundation


struct BusCourse: Decodable{
    let busType: BusType?
    let direction: BusDirection?
    let region: String?
    
    enum CodingKeys: String, CodingKey {
        case busType = "bus_type"
        case direction, region
    }
}

typealias BusCourses = [BusCourse]

extension BusCourse {
    func toDomain() -> BusCourseInfo {
        var busTypeText: String = ""
        var directionText: String = ""
        
        if busType == .shuttleBus {
            busTypeText = "셔틀"
        }
        else if busType == .commuteBus {
            busTypeText = ""
        }
        
        if direction == .from {
            directionText = "하교"
        }
        else {
            directionText = "등교"
        }
        let busCourseText = "\(region ?? "") \(busTypeText) \(directionText)"
        return BusCourseInfo(busCourse: busCourseText, busType: busType ?? .shuttleBus, direction: direction ?? .from, region: region ?? "")
    }
}

extension BusCourses {
    func toDomain() -> [BusCourseInfo] {
        var busCourseList: [BusCourseInfo] = []
        for busCourse in self {
            busCourseList.append(busCourse.toDomain())
        }
        return busCourseList
    }
}
