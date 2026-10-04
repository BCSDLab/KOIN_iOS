//
//  RecruitApplyRequest.swift
//  koin
//
//  Created by 홍기정 on 9/27/26.
//

import Foundation

struct RecruitApplyRequest {
    var selectedRole: RecruitRole?
    var motivation: String?
    var availableTime: String?
}

extension RecruitApplyRequest {
    func isValid(for type: RecruitRoleType) -> Bool {
        guard (type != .roleBased || selectedRole != nil),
              let motivation, !motivation.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty,
              let availableTime, !availableTime.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
            return false
        }
        return true
    }
}
