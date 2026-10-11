//
//  RecruitApplicantListRequestDto.swift
//  koin
//
//  Created by 홍기정 on 10/4/26.
//

import Foundation

struct RecruitApplicantListRequestDto: Encodable {
    let statuses: [RecruitApplicationStatusDto]?
    let page: Int
    let limit: Int
}
