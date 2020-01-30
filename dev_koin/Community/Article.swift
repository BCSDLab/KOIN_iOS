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

struct Comment: Codable, Hashable {
    let id: Int
    let articleId: Int
    let content: String
    let userId: Int
    let nickname: String
    let isDeleted: Bool
    let grantEdit: Bool
    let grantDelete: Bool
    let createdAt: String
    let updateAt: String
    private enum CodingKeys: String, CodingKey {
            case id = "id"
            case articleId = "article_id"
            case content = "content"
            case userId = "user_id"
            case nickname = "nickname"
            case isDeleted = "is_deleted"
            case grantEdit = "grantEdit"
            case grantDelete = "grantDelete"
            case createdAt = "created_at"
            case updateAt = "updated_at"
    }
}

struct Article: Codable, Hashable {
    let boardId: Int
    let board: Board?
    let comments: [Comment]?
    let commentCount: Int
    let content: String
    let contentSummary: String
    let createdAt: String
    let hit: Int
    let id: Int
    let ip: String?
    let isDeleted: Bool?
    let isNotice: Bool
    let isSolved: Bool
    let meta: String?
    let nickname: String
    let noticeArticleId: String?
    let summary: String?
    let title: String
    let updatedAt: String
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
