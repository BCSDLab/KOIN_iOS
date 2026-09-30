//
//  RecruitApplication.swift
//  koin
//
//  Created by 홍기정 on 9/27/26.
//

import Foundation

struct RecruitApplication {
    let applicationId: Int
    var status: RecruitMyApplicationStatus
    let profile: RecruitProfile
    let motivation: String
    let availableTime: String
    let role: String?
    let canDecide: Bool
    let canDirectChat: Bool
}

extension RecruitApplication {
    mutating func decided(as decision: RecruitApplicationDecision) {
        switch decision {
        case .accepted:
            self.status = .accepted
        case .denied:
            self.status = .denied
        }
    }
}
