//
//  RecruitProfileRequest.swift
//  koin
//
//  Created by 홍기정 on 9/13/26.
//

import Foundation

struct RecruitProfileRequest {
    var nickname: String? = nil
    var preferredRole: String? = nil
    var skills: [String] = []
    var activities: [RecruitProfileActivityRequest] = []
    var introduction: String? = nil
}
