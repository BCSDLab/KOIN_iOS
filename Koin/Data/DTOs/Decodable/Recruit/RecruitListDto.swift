//
//  RecruitListDto.swift
//  koin
//
//  Created by 홍기정 on 10/1/26.
//

import Foundation

struct RecruitListDto: Decodable {
    let recruitments: [RecruitListSummaryDto]
    let totalCount: Int
    let currentCount: Int
    let totalPage: Int
    let currentPage: Int

    enum CodingKeys: String, CodingKey {
        case recruitments
        case totalCount = "total_count"
        case currentCount = "current_count"
        case totalPage = "total_page"
        case currentPage = "current_page"
    }
}

extension RecruitListDto {
    func toDomain() -> RecruitList {
        return RecruitList(
            recruits: recruitments.map { $0.toDomain() },
            totalCount: totalCount,
            totalPage: totalPage,
            currentPage: currentPage
        )
    }
}
