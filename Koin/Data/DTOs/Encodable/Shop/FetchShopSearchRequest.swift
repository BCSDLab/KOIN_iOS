//
//  FetchShopSearchRequest.swift
//  koin
//
//  Created by 홍기정 on 11/8/25.
//

import Foundation

struct FetchShopSearchRequest: Encodable {
    let keyword: String
    
    enum CodingKeys: String, CodingKey {
        case keyword
    }
}
