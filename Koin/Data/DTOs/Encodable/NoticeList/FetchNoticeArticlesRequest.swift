//
//  FetchNoticeArticlesRequest.swift
//  koin
//
//  Created by JOOMINKYUNG on 8/17/24.
//

import Foundation

struct FetchNoticeArticlesRequest: Encodable {
    let boardId: Int
    let page: Int?
    let limit: Int?
}
