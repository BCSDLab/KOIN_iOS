//
//  RecruitApplication.swift
//  koin
//
//  Created by 홍기정 on 9/28/26.
//

import Foundation

struct RecruitApplication: Identifiable, Equatable {
    let applicationId: Int
    let nickname: String
    let department: String
    let studentYear: Int
    let role: String
    let status: RecruitMyApplicationStatus
    let canChat: Bool
}

extension RecruitApplication {
    var id: Int {
        return applicationId
    }
}
