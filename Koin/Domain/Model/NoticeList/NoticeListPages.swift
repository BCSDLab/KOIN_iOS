//
//  NoticeListPages.swift
//  koin
//
//  Created by JOOMINKYUNG on 8/17/24.
//

import Foundation

struct NoticeListPages {
    let isPreviousPage: PageReloadDirection?
    let pages: [Int]
    let selectedIndex: Int
    let isNextPage: PageReloadDirection?
}

enum PageReloadDirection: String {
    case previousPage = "이전"
    case nextPage = "다음"
}
