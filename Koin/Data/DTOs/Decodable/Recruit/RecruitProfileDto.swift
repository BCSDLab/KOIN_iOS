//
//  RecruitProfileDto.swift
//  koin
//
//  Created by 홍기정 on 10/3/26.
//

import Foundation

struct RecruitProfileDto: Decodable {
    let profileNickname: String
    let department: String
    let major: String?
    let studentNumber: String
    let preferredRole: String
    let skills: [String]
    let activities: [RecruitProfileActivityDto]
    let selfIntroduction: String

    enum CodingKeys: String, CodingKey {
        case profileNickname = "profile_nickname"
        case department, major
        case studentNumber = "student_number"
        case preferredRole = "preferred_role"
        case skills, activities
        case selfIntroduction = "self_introduction"
    }
}

struct RecruitProfileActivityDto: Decodable {
    let id: Int
    let title: String
    let startedAt: String
    let endedAt: String?
    let isOngoing: Bool
    let description: String

    enum CodingKeys: String, CodingKey {
        case id, title
        case startedAt = "started_at"
        case endedAt = "ended_at"
        case isOngoing = "is_ongoing"
        case description
    }
}

extension RecruitProfileDto {
    func toDomain() -> RecruitProfile {
        return RecruitProfile(
            nickname: profileNickname,
            department: department,
            studentNumber: studentNumber,
            preferredRole: preferredRole,
            skills: skills,
            activities: activities.compactMap { $0.toDomain() },
            selfIntroduction: selfIntroduction
        )
    }
}

extension RecruitProfileActivityDto {
    func toDomain() -> RecruitProfileActivity? {
        guard let startedAt = startedAt.toDateFromYYYYMMDD() else {
            return nil
        }
        return RecruitProfileActivity(
            id: id,
            title: title,
            startedAt: startedAt,
            endedAt: endedAt?.toDateFromYYYYMMDD(),
            isOngoing: isOngoing,
            description: description
        )
    }
}
