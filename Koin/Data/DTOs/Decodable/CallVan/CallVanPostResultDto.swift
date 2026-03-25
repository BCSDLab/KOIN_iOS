//
//  CallVanPostResultDto.swift
//  koin
//
//  Created by 홍기정 on 3/15/26.
//

import Foundation

struct CallVanPostResultDto: Decodable {
    let id: Int
    let author: String?
    let departureType: CallVanPlaceDto
    let departureCustomName: String?
    let arrivalType: CallVanPlaceDto
    let arrivalCustomName: String?
    let departureDate: String
    let departureTime: String
    let maxParticipants: Int
    let currentParticipants: Int
    let state: CallVanStateDto
    let createdAt: String
    let updatedAt: String

    enum CodingKeys: String, CodingKey {
        case id, author
        case departureType = "departure_type"
        case departureCustomName = "departure_custom_name"
        case arrivalType = "arrival_type"
        case arrivalCustomName = "arrival_custom_name"
        case departureDate = "departure_date"
        case departureTime = "departure_time"
        case maxParticipants = "max_participants"
        case currentParticipants = "current_participants"
        case state = "status"
        case createdAt = "created_at"
        case updatedAt = "updated_at"
    }
}

extension CallVanPostResultDto {
    
    func toDomain() -> CallVanListPost {
        let callVanListPostDto = CallVanListPostDto(
            postId: id,
            title: "",
            departure: departureCustomName ?? departureType.toDomain().rawValue,
            arrival: arrivalCustomName ?? arrivalType.toDomain().rawValue,
            departureDate: departureDate,
            departureTime: departureTime,
            authorNickname: author,
            currentParticipants: currentParticipants,
            maxParticipants: maxParticipants,
            state: state,
            isJoined: true,
            isAuthor: true
        )
        return callVanListPostDto.toDomain()
    }
}
