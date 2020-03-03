//
//  Articles.swift
//  dev_koin
//
//  Created by 정태훈 on 2020/01/22.
//  Copyright © 2020 정태훈. All rights reserved.
//

import Foundation

struct Articles: Codable {
    var articles: [Article]
    private enum CodingKeys: String, CodingKey {
        case articles = "articles"
    }
    init(articles: [Article]) {
        self.articles = articles
    }

    init() {
        self.articles = [Article()]
    }
}
