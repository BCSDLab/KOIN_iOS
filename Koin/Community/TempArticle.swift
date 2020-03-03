//
//  TempArticle.swift
//  dev_koin
//
//  Created by 정태훈 on 2020/02/12.
//  Copyright © 2020 정태훈. All rights reserved.
//

import Foundation

struct TempComment: Codable, Hashable {
    let id: Int
    let articleId: Int
    let content: String
    let nickname: String
    //let password: String?
    let isDeleted: Bool?
    let createdAt: String
    let updateAt: String
    private enum CodingKeys: String, CodingKey {
            case id = "id"
            case articleId = "article_id"
            case content = "content"
            case nickname = "nickname"
            case isDeleted = "is_deleted"
            //case password = "password"
            case createdAt = "created_at"
            case updateAt = "updated_at"
    }
}

struct TempArticle: Codable, Hashable {
    var comments: [TempComment]?
    var commentCount: Int?
    var content: String?
    var contentSummary: String?
    var createdAt: String
    var hit: Int
    var id: Int
    var isDeleted: Bool?
    //let password: String?
    var nickname: String
    var title: String
    var updatedAt: String
    private enum CodingKeys: String, CodingKey {
        case comments = "comments"
        case commentCount = "comment_count"
        case content = "content"
        case contentSummary = "contentSummary"
        case createdAt = "created_at"
        case hit = "hit"
        case id = "id"
        case isDeleted = "is_deleted"
        //case password = "password"
        case nickname = "nickname"
        case title = "title"
        case updatedAt = "updated_at"
    }
    init() {
        self.commentCount = 0
        self.comments = nil
        self.content = ""
        self.contentSummary = ""
        self.createdAt = "2020-01-01 00:00:00"
        self.hit = 0
        self.id = -1
        self.isDeleted = nil
        self.nickname = ""
        self.title = ""
        self.updatedAt = ""
        //self.password = nil
    }
}
