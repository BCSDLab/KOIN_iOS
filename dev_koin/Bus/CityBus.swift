//
//  CityBus.swift
//  dev_koin
//
//  Created by 정태훈 on 2020/02/09.
//  Copyright © 2020 정태훈. All rights reserved.
//

import Foundation

struct CityBus: Codable, Hashable {
    let busNumber: Int
    let remainTime: Int
    let nextBusNumber: Int
    let nextRemainTime: Int
    private enum CodingKeys: String, CodingKey {
        case busNumber = "bus_number"
        case remainTime = "remain_time"
        case nextBusNumber = "next_bus_number"
        case nextRemainTime = "next_remain_time"
    }
}
