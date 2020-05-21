//
//  CommonArticles.swift
//  Koin
//
//  Created by 정태훈 on 2020/04/13.
//  Copyright © 2020 정태훈. All rights reserved.
//

import Foundation

protocol CommonArticles {
    associatedtype T : CommonArticle
    var articles: [T] { get set }
}

protocol CommonArticle {
    associatedtype T : CommonComment
    var comments: [T]? { get set }
    var commentCount: Int? { get set }
    var content: String? { get set }
    var contentSummary: String? { get set }
    var createdAt: String { get set }
    var hit: Int  { get set }
    var id: Int  { get set }
    var isDeleted: Bool? { get set }
    var nickname: String { get set }
    var title: String { get set }
    var updatedAt: String { get set }
    init()
}

protocol CommonComment {
    var id: Int { get set }
    var articleId: Int { get set }
    var content: String { get set }
    var nickname: String { get set }
    var isDeleted: Bool? { get set }
    var createdAt: String? { get set }
    var updatedAt: String? { get set }
    init()
}
