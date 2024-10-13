//
//  SearchArticleRequest.swift
//  koin
//
//  Created by JOOMINKYUNG on 8/17/24.
//

import Foundation

struct SearchNoticeArticleRequest: Encodable {
    let query: String
    let boardId: Int?
    let page: Int?
    let limit: Int?
}
