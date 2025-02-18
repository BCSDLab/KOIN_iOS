//
//  FetchLostItemsRequest.swift
//  koin
//
//  Created by 김나훈 on 2/17/25.
//

import Foundation

struct FetchLostItemsRequest: Encodable {
    let type: LostItemType?
    let page: Int?
    let limit: Int?
}
