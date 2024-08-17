//
//  NoticeListPages.swift
//  koin
//
//  Created by JOOMINKYUNG on 8/17/24.
//

import Foundation

struct NoticeListPages {
    let isPreviousPage: pageReloadDirection?
    let pages: [Int]
    let isNextPage: pageReloadDirection?
}

enum pageReloadDirection: String {
    case previousPage = "이전"
    case nextPage = "다음"
}
