//
//  NoticeKeysordDTO.swift
//  koin
//
//  Created by JOOMINKYUNG on 8/13/24.
//

import Foundation

struct NoticeKeywordsDTO: Decodable {
    let keywords: [NoticeKeywordDTO]
    
    enum CodingKeys: String, CodingKey {
        case keywords = "keywords"
    }
}

struct NoticeKeywordDTO: Codable {
    let id: Int?
    let keyword: String
    
    enum CodingKeys: String, CodingKey {
        case id
        case keyword = "keyword"
    }
}

struct NoticeRecommendedKeywordDTO: Decodable {
    let keywords: [String]
}
