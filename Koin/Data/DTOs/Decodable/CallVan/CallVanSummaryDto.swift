//
//  CallVanSummaryDto.swift
//  koin
//
//  Created by 홍기정 on 3/17/26.
//

import Foundation

struct CallVanSummaryDto: Decodable {
    let id: Int
    let title: String
    let departure: String
    let arrival: String
    let departureDate: String
    let departureTime: String
    let authorNickname: String?
    let currentParticipants: Int
    let maxParticipants: Int
    let state: CallVanStateDto
    let isJoined: Bool
    let isAuthor: Bool

    enum CodingKeys: String, CodingKey {
        case id, title, departure, arrival
        case departureDate = "departure_date"
        case departureTime = "departure_time"
        case authorNickname = "author_nickname"
        case currentParticipants = "current_participants"
        case maxParticipants = "max_participants"
        case state = "status"
        case isJoined = "is_joined"
        case isAuthor = "is_author"
    }
}

extension CallVanSummaryDto {
    
    func toDomain() -> CallVanListPost {
        let callVanListPostDto = CallVanListPostDto(
            postId: id,
            title: title,
            departure: departure,
            arrival: arrival,
            departureDate: departureDate,
            departureTime: departureTime,
            authorNickname: authorNickname,
            currentParticipants: currentParticipants,
            maxParticipants: maxParticipants,
            state: state,
            isJoined: isJoined,
            isAuthor: isAuthor
        )
        return callVanListPostDto.toDomain()
    }
}
