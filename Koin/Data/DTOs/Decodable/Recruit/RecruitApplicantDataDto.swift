//
//  RecruitApplicantDataDto.swift
//  koin
//
//  Created by 홍기정 on 10/4/26.
//

import Foundation

struct RecruitApplicantDataDto: Decodable {
    let applicationId: Int
    let status: RecruitApplicationStatusDto
    let profileSnapshot: RecruitProfileSnapshotDto
    let motivation: String
    let availability: String
    let role: RecruitApplicationRoleDto?
    let canDecide: Bool
    let canOpenDirectChat: Bool

    enum CodingKeys: String, CodingKey {
        case applicationId = "application_id"
        case status
        case profileSnapshot = "profile_snapshot"
        case motivation, availability, role
        case canDecide = "can_decide"
        case canOpenDirectChat = "can_open_direct_chat"
    }
}

struct RecruitProfileSnapshotDto: Decodable {
    let nickname: String
    let department: String
    let studentYear: Int
    let preferredRole: String
    let skills: [String]
    let activities: [RecruitProfileActivityDto]
    let selfIntroduction: String

    enum CodingKeys: String, CodingKey {
        case nickname, department
        case studentYear = "student_year"
        case preferredRole = "preferred_role"
        case skills, activities
        case selfIntroduction = "self_introduction"
    }
}

extension RecruitApplicantDataDto {
    func toDomain() -> RecruitApplicantData {
        return RecruitApplicantData(
            applicationId: applicationId,
            status: status.toDomain(),
            profile: profileSnapshot.toDomain(),
            motivation: motivation,
            availableTime: availability,
            role: role?.name,
            canDecide: canDecide,
            canDirectChat: canOpenDirectChat
        )
    }
}

extension RecruitProfileSnapshotDto {
    func toDomain() -> RecruitProfile {
        return RecruitProfile(
            nickname: nickname,
            department: department,
            studentNumber: "\(studentYear)",
            preferredRole: preferredRole,
            skills: skills,
            activities: activities.compactMap { $0.toDomain() },
            selfIntroduction: selfIntroduction
        )
    }
}
