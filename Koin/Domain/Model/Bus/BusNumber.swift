//
//  BusNumber.swift
//  koin
//
//  Created by JOOMINKYUNG on 7/29/24.
//

import Foundation

enum BusNumber: Int, Decodable, CaseIterable {
    case fourHundred = 400
    case fourHundredTwo = 402
    case fourHundredFive = 405

    enum CodingKeys: String, CodingKey {
        case rawValue
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        let rawValue = try? container.decode(Int.self)
        self = BusNumber(rawValue: rawValue ?? 400) ?? .fourHundred
    }
}
