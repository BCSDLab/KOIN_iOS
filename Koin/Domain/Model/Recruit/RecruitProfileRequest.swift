//
//  RecruitProfileRequest.swift
//  koin
//
//  Created by 홍기정 on 9/13/26.
//

import Foundation

struct RecruitProfileRequest {
    var preferredRole: String? = nil
    var skills: [String] = []
    var activities: [RecruitProfileActivityRequest] = []
    var introduction: String? = nil
}

extension RecruitProfileRequest {
    var isValid: Bool {
        guard let preferredRole,
              !preferredRole.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty,
              let introduction,
              !introduction.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
            return false
        }

        let normalizedSkills = skills.map {
            $0.trimmingCharacters(in: .whitespacesAndNewlines)
        }
        guard normalizedSkills.allSatisfy({ !$0.isEmpty }),
              Set(normalizedSkills).count == normalizedSkills.count else {
            return false
        }
        
        return activities.allSatisfy(\.isValid)
    }
}
