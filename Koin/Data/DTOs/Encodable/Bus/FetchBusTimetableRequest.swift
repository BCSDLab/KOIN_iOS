//
//  BusTimeTableRequest.swift
//  koin
//
//  Created by JOOMINKYUNG on 7/27/24.
//

import Foundation

struct FetchBusTimetableRequest: Encodable {
    let busType: String
    let direction: String
    let region: String
    
    enum CodingKeys: String, CodingKey {
        case busType = "bus_type"
        case direction
        case region
    }
}
