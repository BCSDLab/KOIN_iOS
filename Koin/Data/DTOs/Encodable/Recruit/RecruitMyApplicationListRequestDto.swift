//
//  RecruitMyApplicationListRequestDto.swift
//  koin
//
//  Created by 홍기정 on 10/4/26.
//

import Foundation

struct RecruitMyApplicationListRequestDto: Encodable {
    let statuses: [RecruitApplicationStatusDto]?
    let sort: RecruitListSortDto
    let page: Int
    let limit: Int?
}

extension RecruitMyApplicationListRequestDto {
    init(from filter: RecruitMyApplicationFilter) {
        self.statuses = filter.status.map { [RecruitApplicationStatusDto(from: $0)] }
        self.sort = RecruitListSortDto(from: filter.sort)
        self.page = filter.page
        self.limit = filter.limit
    }
}
