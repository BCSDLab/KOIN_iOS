//
//  NoticeKeysordDto.swift
//  koin
//
//  Created by JOOMINKYUNG on 8/13/24.
//

import Foundation

struct NoticeKeywordsDto: Decodable {
    let keywords: [NoticeKeywordDto]
    
    enum CodingKeys: String, CodingKey {
        case keywords = "keywords"
    }
}

struct NoticeKeywordDto: Codable {
    let id: Int?
    let keyword: String
    
    enum CodingKeys: String, CodingKey {
        case id
        case keyword = "keyword"
    }
}

struct NoticeRecommendedKeywordDto: Decodable {
    let keywords: [String]
}
