//
//  CallVanPostRequestDto.swift
//  koin
//
//  Created by 홍기정 on 3/15/26.
//

import Foundation

struct CallVanPostRequestDto: Encodable {
    var departureType: CallVanPlaceDto?
    var departureCustomName: String?
    var arrivalType: CallVanPlaceDto?
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
}

extension CallVanPostRequestDto {
    
    init(from model: CallVanPostRequest) {
        departureType = {
            if let departureType = model.departureType {
                return CallVanPlaceDto(from: departureType)
            } else {
                return nil
            }
        }()
        departureCustomName = model.departureCustomName
        arrivalType = {
            if let arrivalType = model.arrivalType {
                return CallVanPlaceDto(from: arrivalType)
            } else {
                return nil
            }
        }()
        arrivalCustomName = model.arrivalCustomName
        departureDate = model.departureDate
        departureTime = model.departureTime
        maxParticipants = model.maxParticipants
    }
}
