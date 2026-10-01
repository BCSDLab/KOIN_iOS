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
