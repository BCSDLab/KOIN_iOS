//
//  CallVanPostRequest.swift
//  koin
//
//  Created by 홍기정 on 3/6/26.
//

import Foundation

struct CallVanPostRequest: Encodable {
    var departureType: CallVanPlace?
    var departureCustomName: String?
    var arrivalType: CallVanPlace?
    var arrivalCustomName: String?
    var departureDate: String? // "yyyy-MM-dd"
    var departureTime: String? // "HH:mm"
    var maxParticipants: Int = 1

    enum CodingKeys: String, CodingKey {
        case departureType = "departure_type"
        case departureCustomName = "departure_custom_name"
        case arrivalType = "arrival_type"
        case arrivalCustomName = "arrival_custom_name"
        case departureDate = "departure_date"
        case departureTime = "departure_time"
        case maxParticipants = "max_participants"
    }
    
    init() {
        departureType = nil
        departureCustomName = nil
        arrivalType = nil
        arrivalCustomName = nil
        departureDate = nil
        departureTime = nil
        maxParticipants = 1
    }
}
