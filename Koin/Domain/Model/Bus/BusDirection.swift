//
//  BusDirection.swift
//  koin
//
//  Created by JOOMINKYUNG on 7/23/24.
//

import Foundation

enum BusDirection: String, Decodable {
    case from = "from"
    case to = "to"
    
    init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        let rawValue = try container.decode(String.self)
        self = BusDirection(rawValue: rawValue) ?? .from
    }
}

enum CityBusDirection: String, Decodable, CaseIterable {
    case byungChun = "병천3리"
    case hwangSaDong = "황사동"
    case yuGwanSun = "유관순열사사적지"
    case terminal = "종합터미널"
    
    init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        let rawValue = try? container.decode(String.self)
        self = CityBusDirection(rawValue: rawValue ?? "") ?? .byungChun
    }
}
