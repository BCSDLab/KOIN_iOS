//
//  RecruitApplicantDecisionRequestDto.swift
//  koin
//
//  Created by 홍기정 on 10/4/26.
//

import Foundation

struct RecruitApplicantDecisionRequestDto: Encodable {
    let status: RecruitApplicationStatusDto
}

extension RecruitApplicantDecisionRequestDto {
    init(from decision: RecruitApplicantDecision) {
        switch decision {
        case .accepted:
            self.status = .accepted
        case .denied:
            self.status = .rejected
        }
    }
}
