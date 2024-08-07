//
//  FetchCityBusTimetableRequest.swift
//  koin
//
//  Created by JOOMINKYUNG on 7/29/24.
//

import Foundation

struct FetchCityBusTimetableRequest: Encodable {
    let busNumber: Int
    let direction: String
    
    enum CodingKeys: String, CodingKey {
        case busNumber = "bus_number"
        case direction
    }
}
