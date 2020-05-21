//
//  SearchResponse.swift
//  Koin
//
//  Created by 정태훈 on 2020/05/01.
//  Copyright © 2020 정태훈. All rights reserved.
//

import Foundation

struct SearchResponse: Codable {
    let totalPage: Int
    let articles: [SearchItem]
    
    enum SearchResponse {
        case totalPage
        case articles
    }
    
    struct SearchItem: Codable {
        let id: Int
        let tableId: Int
        let serviceName: String
        let title: String
        let userId: Int?
        let nickname: String
        let hit: Int
        let commentCount: Int?
        let permalink: String
        let createdAt: String
        let updatedAt: String
        
        enum CodingKeys: String, CodingKey {
            case id
            case tableId = "table_id"
            case serviceName = "service_name"
            case title
            case userId = "user_id"
            case nickname
            case hit
            case commentCount = "comment_count"
            case permalink
            case createdAt = "created_at"
            case updatedAt = "updated_at"
        }
    }
}
