//
//  RecruitEnumDto.swift
//  koin
//
//  Created by 홍기정 on 10/1/26.
//

import Foundation

enum RecruitCategoryDto: String, Codable {
    case contest = "CONTEST"
    case externalActivity = "EXTERNAL_ACTIVITY"
    case study = "STUDY"
    case project = "PROJECT"
    case other = "OTHER"
}

enum RecruitMeetingTypeDto: String, Codable {
    case online = "ONLINE"
    case offline = "OFFLINE"
    case mixed = "MIXED"
}

enum RecruitStatusDto: String, Decodable {
    case recruiting = "RECRUITING"
    case closed = "CLOSED"
}

enum RecruitRoleTypeDto: String, Decodable {
    case roleBased = "ROLE_BASED"
    case general = "GENERAL"
}

enum RecruitApplicationStatusDto: String, Decodable {
    case pending = "PENDING"
    case accepted = "ACCEPTED"
    case rejected = "REJECTED"
}

enum RecruitApplyBlockReasonDto: String, Decodable {
    case recruitmentDeleted = "RECRUITMENT_DELETED"
    case loginRequired = "LOGIN_REQUIRED"
    case ownRecruitment = "OWN_RECRUITMENT"
    case alreadyApplied = "ALREADY_APPLIED"
    case recruitmentClosed = "RECRUITMENT_CLOSED"
    case deadlinePassed = "DEADLINE_PASSED"
    case roleClosed = "ROLE_CLOSED"
    case profileRequired = "PROFILE_REQUIRED"
}

extension RecruitCategoryDto {
    init(from model: RecruitCategory) {
        switch model {
        case .contest:
            self = .contest
        case .externalActivity:
            self = .externalActivity
        case .study:
            self = .study
        case .project:
            self = .project
        case .other:
            self = .other
        }
    }

    func toDomain() -> RecruitCategory {
        switch self {
        case .contest:
            return .contest
        case .externalActivity:
            return .externalActivity
        case .study:
            return .study
        case .project:
            return .project
        case .other:
            return .other
        }
    }
}

extension RecruitMeetingTypeDto {
    init(from model: RecruitMeetingType) {
        switch model {
        case .online:
            self = .online
        case .offline:
            self = .offline
        case .mixed:
            self = .mixed
        }
    }

    func toDomain() -> RecruitMeetingType {
        switch self {
        case .online:
            return .online
        case .offline:
            return .offline
        case .mixed:
            return .mixed
        }
    }
}

extension RecruitStatusDto {
    func toDomain() -> RecruitState {
        switch self {
        case .recruiting:
            return .recruiting
        case .closed:
            return .closed
        }
    }
}

extension RecruitRoleTypeDto {
    func toDomain() -> RecruitRoleType {
        switch self {
        case .roleBased:
            return .roleBased
        case .general:
            return .general
        }
    }
}

extension RecruitApplicationStatusDto {
    func toDomain() -> RecruitApplicationStatus {
        switch self {
        case .pending:
            return .pending
        case .accepted:
            return .accepted
        case .rejected:
            return .denied
        }
    }
}

extension RecruitApplyBlockReasonDto {
    func toDomain() -> RecruitApplyBlockReason {
        switch self {
        case .recruitmentDeleted:
            return .recruitmentDeleted
        case .loginRequired:
            return .loginRequired
        case .ownRecruitment:
            return .ownRecruitment
        case .alreadyApplied:
            return .alreadyApplied
        case .recruitmentClosed:
            return .recruitmentClosed
        case .deadlinePassed:
            return .deadlinePassed
        case .roleClosed:
            return .roleClosed
        case .profileRequired:
            return .profileRequired
        }
    }
}
