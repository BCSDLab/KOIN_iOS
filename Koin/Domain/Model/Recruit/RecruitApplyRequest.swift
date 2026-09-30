//
//  RecruitApplyRequest.swift
//  koin
//
//  Created by 홍기정 on 9/27/26.
//

import Foundation

struct RecruitApplyRequest {
    let recruit: RecruitData
    var basicInfo = BasicInfo()
    var skills: [String] = []
    var activities: [RecruitProfileActivityRequest] = []
    var introduction: String?
    var selectedRole: RecruitRole?
    var motivation: String?
    var availableTime: String?
}

extension RecruitApplyRequest {
    var isFirstStepValid: Bool {
        guard basicInfo.isValid,
              let introduction,
              !introduction.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
            return false
        }

        let normalizedSkills = skills.map {
            $0.trimmingCharacters(in: .whitespacesAndNewlines)
        }
        return normalizedSkills.allSatisfy { !$0.isEmpty }
            && Set(normalizedSkills).count == normalizedSkills.count
            && activities.allSatisfy(\.isValid)
    }

    var isSecondStepValid: Bool {
        guard (recruit.type != .roleBased || selectedRole != nil),
              let motivation,
              !motivation.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty,
              let availableTime,
              !availableTime.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
            return false
        }
        return true
    }
}
