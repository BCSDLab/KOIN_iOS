//
//  SearchBusInfoRequest.swift
//  koin
//
//  Created by JOOMINKYUNG on 7/26/24.
//

import Foundation

struct SearchBusInfoRequest: Encodable {
    let date: String
    let time: String
    let busType: String
    let depart: String
    let arrival: String
}
