//
//  Article.swift
//  dev_koin
//
//  Created by 정태훈 on 2020/01/22.
//  Copyright © 2020 정태훈. All rights reserved.
//

import Foundation

struct Article: Codable, Hashable {
    let boardId: Int
    let commentCount: Int
    let content: String
    let contentSummary: String
    let createdAt: String
    let hit: Int
    let id: Int
    let ip: String
    let isDeleted: Bool
    let isNotice: Bool
    let isSolved: Bool
    let meta: String?
    let nickname: String
    let noticeArticleId: String?
    let summary: String?
    let title: String
    let updatedAt: String
    let userId: Int
    private enum CodingKeys: String, CodingKey {
        case boardId = "board_id"
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
        self.commentCount = 0
        self.content = ""
        self.contentSummary = ""
        self.createdAt = ""
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
