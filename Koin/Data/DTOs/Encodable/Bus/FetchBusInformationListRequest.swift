//
//  FetchDiningListRequest.swift
//  koin
//
//  Created by JOOMINKYUNG on 7/23/24.
//

import Foundation

struct FetchBusInformationListRequest: Encodable {
    let busType: String
    let depart: String
    let arrival: String
    
    enum CodingKeys: String, CodingKey {
        case busType = "bus_type"
        case depart 
        case arrival
    }
}
