//
//  RecruitApplicantData.swift
//  koin
//
//  Created by 홍기정 on 9/27/26.
//

import Foundation

struct RecruitApplicantData {
    let applicationId: Int
    private(set) var status: RecruitApplicationStatus
    let profile: RecruitProfile
    let motivation: String
    let availableTime: String
    let role: String?
    private(set) var canDecide: Bool
    private(set) var canDirectChat: Bool
}

extension RecruitApplicantData {
    mutating func decided(as decision: RecruitApplicantDecision) {
        switch decision {
        case .accepted:
            self.status = .accepted
            self.canDirectChat = true
        case .denied:
            self.status = .denied
        }
        
        canDecide = false
    }
}
