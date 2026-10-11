//
//  RecruitRoleDto.swift
//  koin
//
//  Created by 홍기정 on 10/1/26.
//

import Foundation

struct RecruitRoleDto: Decodable {
    let id: Int
    let name: String
    let currentParticipants: Int
    let maxParticipants: Int
    let isClosed: Bool

    enum CodingKeys: String, CodingKey {
        case id, name
        case currentParticipants = "current_participants"
        case maxParticipants = "max_participants"
        case isClosed = "is_closed"
    }
}

extension RecruitRoleDto {
    func toDomain() -> RecruitRole {
        return RecruitRole(
            id: id,
            name: name,
            currentParticipants: currentParticipants,
            maximumParticipants: maxParticipants,
            isClosed: isClosed
        )
    }
}
