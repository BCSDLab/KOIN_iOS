//
//  NoticeKeyWordDTO.swift
//  koin
//
//  Created by JOOMINKYUNG on 8/13/24.
//

import Foundation

struct NoticeKeyWordsDTO: Decodable {
    let keyWords: [NoticeKeyWordDTO]
    
    enum CodingKeys: String, CodingKey {
        case keyWords = "keywords"
    }
}

struct NoticeKeyWordDTO: Codable {
    let id: Int?
    let keyWord: String
    
    enum CodingKeys: String, CodingKey {
        case id
        case keyWord = "keyword"
    }
}
