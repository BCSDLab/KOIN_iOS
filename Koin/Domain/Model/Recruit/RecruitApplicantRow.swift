//
//  RecruitApplicantRow.swift
//  koin
//
//  Created by 홍기정 on 9/28/26.
//

import Foundation

struct RecruitApplicantRow: Identifiable, Equatable {
    let applicationId: Int
    let nickname: String
    let department: String
    let studentYear: Int
    let role: String
    let status: RecruitApplicationStatus
    let canChat: Bool
}

extension RecruitApplicantRow {
    var id: Int {
        return applicationId
    }
}
