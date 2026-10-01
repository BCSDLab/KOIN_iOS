//
//  RecruitApplicantData.swift
//  koin
//
//  Created by 홍기정 on 9/27/26.
//

import Foundation

struct RecruitApplicantData {
    let applicationId: Int
    var status: RecruitApplicationStatus
    let profile: RecruitProfile
    let motivation: String
    let availableTime: String
    let role: String?
    let canDecide: Bool
    let canDirectChat: Bool
}

extension RecruitApplicantData {
    mutating func decided(as decision: RecruitApplicantDecision) {
        switch decision {
        case .accepted:
            self.status = .accepted
        case .denied:
            self.status = .denied
        }
    }
}
