//
//  LostItemKeywordDto.swift
//  koin
//
//  Created by 홍기정 on 5/12/26.
//

import Foundation

struct LostItemKeywordSuggestionDto: Decodable {
    let keywords: [String]
    
    func toDomain() -> [String] {
        return keywords
    }
}

struct LostItemKeywordsDto: Decodable {
    let count: Int
    let keywords: [LostItemKeywordDto]
    
    func toDomain() -> LostItemKeywords {
        return LostItemKeywords(count: count, keywords: keywords.map { $0.toDomain() })
    }
}

struct LostItemKeywordDto: Decodable {
    let id: Int
    let keyword: String
    
    func toDomain() -> LostItemKeyword {
        return LostItemKeyword(id: id, keyword: keyword)
    }
}
