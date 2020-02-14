//
//  TempArticles.swift
//  dev_koin
//
//  Created by 정태훈 on 2020/02/12.
//  Copyright © 2020 정태훈. All rights reserved.
//

import Foundation

struct TempArticles: Codable {
    var totalPage: Int
    var articles: [TempArticle]
    private enum CodingKeys: String, CodingKey {
        case articles = "articles"
        case totalPage = "totalPage"
    }
    init(articles: [TempArticle]) {
        self.articles = articles
        self.totalPage = 999
    }

    init() {
        self.articles = [TempArticle()]
        self.totalPage = 999
    }
}
