//
//  RecruitMyPostListRequestDto.swift
//  koin
//
//  Created by 홍기정 on 10/4/26.
//

import Foundation

struct RecruitMyPostListRequestDto: Encodable {
    let status: RecruitListStatusDto
    let sort: RecruitListSortDto
    let page: Int
    let limit: Int?
}

extension RecruitMyPostListRequestDto {
    init(from filter: RecruitMyPostFilter) {
        self.status = RecruitListStatusDto(from: filter.state)
        self.sort = RecruitListSortDto(from: filter.sort)
        self.page = filter.page
        self.limit = filter.limit
    }
}
