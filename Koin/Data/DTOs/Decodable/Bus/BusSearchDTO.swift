//
//  BusSearchDTO.swift
//  koin
//
//  Created by JOOMINKYUNG on 2024/04/03.
//. nullable 주민경 20204/05/02

import Foundation

struct BusSearch: Decodable {
    let busName: BusType?
    let busTime: String?

    enum CodingKeys: String, CodingKey {
        case busName = "bus_name"
        case busTime = "bus_time"
    }
}

typealias BusSearchDTO = [BusSearch]

extension BusSearchDTO {
    func toDomain() -> SearchBusInfoResult {
        var shuttleTime: String?
        var expressTime: String?
        var commuteTime: String?
        for bus in self {
            switch bus.busName {
            case .shuttleBus:
                shuttleTime = bus.busTime 
            case .expressBus:
                expressTime = bus.busTime
            default:
                commuteTime = bus.busTime
            }
        }
        return SearchBusInfoResult(shuttleTime: shuttleTime, expressTime: expressTime, commutingTime: commuteTime)
    }
}
