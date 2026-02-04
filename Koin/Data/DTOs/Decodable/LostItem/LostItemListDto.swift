//
//  LostItemListDto.swift
//  koin
//
//  Created by 홍기정 on 1/21/26.
//

import Foundation

struct LostItemListDto: Decodable {
    let articles: [LostItemListDataDto]
    let totalCount, currentCount, totalPage, currentPage: Int
    
    enum CodingKeys: String, CodingKey {
        case articles
        case totalCount = "total_count"
        case currentCount = "current_count"
        case totalPage = "total_page"
        case currentPage = "current_page"
    }
}

extension LostItemListDto {
    
    func toDomain() -> LostItemList {
        return LostItemList(
            articles: self.articles.map {
                return $0.toDomain()
            },
            totalCount: self.totalCount,
            currentCount: self.currentCount,
            totalPage: self.totalPage,
            currentPage: self.currentPage)
    }
}
