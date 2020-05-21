//
//  TempArticles.swift
//  dev_koin
//
//  Created by 정태훈 on 2020/02/12.
//  Copyright © 2020 정태훈. All rights reserved.
//

import Foundation

struct TempArticles: Codable, CommonArticles  {
    
    var articles: [TempArticle]
    private enum CodingKeys: String, CodingKey {
        case articles = "articles"
    }
    init(articles: [TempArticle]) {
        self.articles = articles
    }
    

    init() {
        self.articles = [TempArticle()]
    }
}
