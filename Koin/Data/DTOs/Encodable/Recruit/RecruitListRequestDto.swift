//
//  RecruitListRequestDto.swift
//  koin
//
//  Created by 홍기정 on 10/1/26.
//

import Foundation

struct RecruitListRequestDto: Encodable {
    let keyword: String?
    let status: RecruitListStatusDto
    let categories: [RecruitCategoryDto]?
    let meetingType: RecruitMeetingTypeDto?
    let sort: RecruitListSortDto
    let page: Int
    let limit: Int?

    enum CodingKeys: String, CodingKey {
        case keyword, status, categories
        case meetingType = "meetingType"
        case sort, page, limit
    }
}

enum RecruitListStatusDto: String, Encodable {
    case all = "ALL"
    case recruiting = "RECRUITING"
    case closed = "CLOSED"
}

enum RecruitListSortDto: String, Encodable {
    case latestDesc = "LATEST_DESC"
    case deadlineAsc = "DEADLINE_ASC"
}

extension RecruitListRequestDto {
    init(from filter: RecruitListFilter) {
        let keyword = filter.keyword?.trimmingCharacters(in: .whitespacesAndNewlines)
        
        self.keyword = (keyword?.isEmpty ?? true) ? nil : keyword
        self.status = RecruitListStatusDto(from: filter.state)
        self.categories = filter.category.isEmpty ? nil : filter.category
            .sorted { $0.index < $1.index }
            .map { RecruitCategoryDto(from: $0) }
        self.meetingType = filter.meetingType.map { RecruitMeetingTypeDto(from: $0) }
        self.sort = RecruitListSortDto(from: filter.sort)
        self.page = filter.page
        self.limit = filter.limit
    }
}

extension RecruitListStatusDto {
    init(from model: RecruitState) {
        switch model {
        case .all:
            self = .all
        case .recruiting:
            self = .recruiting
        case .closed:
            self = .closed
        }
    }
}

extension RecruitListSortDto {
    init(from model: RecruitListSort) {
        switch model {
        case .latestDescending:
            self = .latestDesc
        case .deadlineAscending:
            self = .deadlineAsc
        }
    }
}
