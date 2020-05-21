//
//  Article.swift
//  dev_koin
//
//  Created by 정태훈 on 2020/01/22.
//  Copyright © 2020 정태훈. All rights reserved.
//

import Foundation

struct Board: Codable, Hashable {
    let id: Int
    let tag: String
    let name: String
    let isAnonymous: Bool
    let articleCount: Int
    let isDeleted: Bool
    let isNotice: Bool
    let parentId: Int?
    let seq: Int
    let children: String?
    let createdAt: String
    let updatedAt: String
    private enum CodingKeys: String, CodingKey {
        case id = "id"
        case tag = "tag"
        case name = "name"
        case isAnonymous = "is_anonymous"
        case articleCount = "article_count"
        case isDeleted = "is_deleted"
        case isNotice = "is_notice"
        case parentId = "parent_id"
        case seq = "seq"
        case children = "children"
        case createdAt = "created_at"
        case updatedAt = "updated_at"
    }
}

struct Comment: Codable, Hashable, CommonComment {
    var id: Int
    var articleId: Int
    var content: String
    var nickname: String
    var isDeleted: Bool?
    let grantEdit: Bool?
    let grantDelete: Bool?
    let userId: Int
    var createdAt: String?
    var updatedAt: String?
    private enum CodingKeys: String, CodingKey {
            case id = "id"
            case userId = "user_id"
            case articleId = "article_id"
            case content = "content"
            case nickname = "nickname"
            case isDeleted = "is_deleted"
            case grantEdit = "grantEdit"
            case grantDelete = "grantDelete"
            case createdAt = "created_at"
            case updatedAt = "updated_at"
    }
    init() {
        self.id = -1
        self.articleId = -1
        self.content = ""
        self.nickname = ""
        self.isDeleted = nil
        self.grantEdit = nil
        self.grantDelete = nil
        self.createdAt = nil
        self.updatedAt = nil
        self.userId = -1
    }
}

struct Article: Codable, Hashable, CommonArticle {
    let boardId: Int
    let board: Board?
    var comments: [Comment]?
    var commentCount: Int?
    var content: String?
    var contentSummary: String?
    var createdAt: String
    var hit: Int
    var id: Int
    let ip: String?
    var isDeleted: Bool?
    let isNotice: Bool
    let isSolved: Bool
    let meta: String?
    var nickname: String
    let noticeArticleId: String?
    let summary: String?
    var title: String
    var updatedAt: String
    let userId: Int?
    private enum CodingKeys: String, CodingKey {
        case board = "board"
        case boardId = "board_id"
        case comments = "comments"
        case commentCount = "comment_count"
        case content = "content"
        case contentSummary = "contentSummary"
        case createdAt = "created_at"
        case hit = "hit"
        case id = "id"
        case ip = "ip"
        case isDeleted = "is_deleted"
        case isNotice = "is_notice"
        case isSolved = "is_solved"
        case meta = "meta"
        case nickname = "nickname"
        case noticeArticleId = "notice_article_id"
        case summary = "summary"
        case title = "title"
        case updatedAt = "updated_at"
        case userId = "user_id"
    }
    init() {
        self.boardId = -1
        self.board = nil
        self.commentCount = 0
        self.comments = nil
        self.content = ""
        self.contentSummary = ""
        self.createdAt = "2020-01-01 00:00:00"
        self.hit = 0
        self.id = -1
        self.ip = ""
        self.isDeleted = false
        self.isNotice = false
        self.isSolved = false
        self.meta = nil
        self.nickname = ""
        self.noticeArticleId = nil
        self.summary = nil
        self.title = ""
        self.updatedAt = ""
        self.userId = -1
    }
}
