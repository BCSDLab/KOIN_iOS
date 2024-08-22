//
//  NoticeKeyWordDTO.swift
//  koin
//
//  Created by JOOMINKYUNG on 8/13/24.
//

import Foundation

struct NoticeKeyWordsDTO: Decodable {
    let counts: Int
    let keyWords: [NoticeKeyWordDTO]
    
    enum CodingKeys: String, CodingKey {
        case counts
        case keyWords = "keywords"
    }
}

struct NoticeKeyWordDTO: Decodable {
    let id: Int
    let keyWord: String
    
    enum CodingKeys: String, CodingKey {
        case id
        case keyWord = "keyword"
    }
}
