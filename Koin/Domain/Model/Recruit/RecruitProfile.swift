//
//  RecruitProfile.swift
//  koin
//
//  Created by 홍기정 on 9/13/26.
//

import Foundation

struct RecruitProfile {
    let nickname: String
    let department: String
    let studentNumber: String
    let preferredRole: String
    let skills: [String]
    let activities: [RecruitProfileActivity]
    let selfIntroduction: String
}

extension RecruitProfile {
    func toBasicInfo() -> BasicInfo {
        BasicInfo(
            nickname: nickname,
            department: department,
            studentNumber: studentNumber
        )
    }
    
    func toRequest() -> RecruitProfileRequest {
        RecruitProfileRequest(
            preferredRole: preferredRole,
            skills: skills,
            activities: activities.map { $0.toRequest() },
            introduction: selfIntroduction
        )
    }
}
