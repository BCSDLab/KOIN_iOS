//
//  RecruitProfileRequestDto.swift
//  koin
//
//  Created by 홍기정 on 10/4/26.
//

import Foundation

struct RecruitProfileRequestDto: Encodable {
    let profileNickname: String
    let preferredRole: String
    let skills: [String]
    let activities: [RecruitProfileActivityRequestDto]
    let selfIntroduction: String

    enum CodingKeys: String, CodingKey {
        case profileNickname = "profile_nickname"
        case preferredRole = "preferred_role"
        case skills, activities
        case selfIntroduction = "self_introduction"
    }
}

struct RecruitProfileActivityRequestDto: Encodable {
    let title: String
    let startedAt: String
    let endedAt: String?
    let isOngoing: Bool
    let description: String

    enum CodingKeys: String, CodingKey {
        case title
        case startedAt = "started_at"
        case endedAt = "ended_at"
        case isOngoing = "is_ongoing"
        case description
    }
}

extension RecruitProfileRequestDto {
    init?(from request: RecruitProfileRequest) {
        guard let nickname = request.nickname,
              let preferredRole = request.preferredRole,
              let introduction = request.introduction else {
            return nil
        }
        var activities: [RecruitProfileActivityRequestDto] = []
        for activity in request.activities {
            guard let activity = RecruitProfileActivityRequestDto(from: activity) else {
                return nil
            }
            activities.append(activity)
        }

        self.profileNickname = nickname
        self.preferredRole = preferredRole
        self.skills = request.skills
        self.activities = activities
        self.selfIntroduction = introduction
    }
}

extension RecruitProfileActivityRequestDto {
    init?(from request: RecruitProfileActivityRequest) {
        guard let title = request.title,
              let startedAt = request.startedAt,
              let description = request.description else {
            return nil
        }
        self.title = title
        self.startedAt = startedAt.formatDateToYYYYMMDD(separator: "-")
        self.endedAt = request.isOngoing ? nil : request.endedAt?.formatDateToYYYYMMDD(separator: "-")
        self.isOngoing = request.isOngoing
        self.description = description
    }
}
