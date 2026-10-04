//
//  RecruitApplyRequestDto.swift
//  koin
//
//  Created by 홍기정 on 10/4/26.
//

import Foundation

struct RecruitApplyRequestDto: Encodable {
    let roleId: Int?
    let motivation: String
    let availability: String

    enum CodingKeys: String, CodingKey {
        case roleId = "role_id"
        case motivation, availability
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(roleId, forKey: .roleId)
        try container.encode(motivation, forKey: .motivation)
        try container.encode(availability, forKey: .availability)
    }
}

extension RecruitApplyRequestDto {
    init?(from request: RecruitApplyRequest) {
        guard let motivation = request.motivation,
              let availableTime = request.availableTime else {
            return nil
        }
        self.roleId = request.selectedRole?.id
        self.motivation = motivation
        self.availability = availableTime
    }
}
