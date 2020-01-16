//
// Created by 정태훈 on 2020/01/13.
// Copyright (c) 2020 정태훈. All rights reserved.
//

import Foundation
import Combine

struct StoreEvent: Codable, Hashable, Identifiable {
    let id: Int
    let shopId: Int
    let title: String
    let eventTitle: String
    let content: String
    let userId: Int
    let nickname: String
    let thumbnail: String?
    let hit: Int?
    let ip: String?
    let startDate: String
    let endDate: String
    let commentCount: Int?
    let isDeleted: Bool?

    private enum CodingKeys: String, CodingKey {
        case id = "id"
        case shopId = "shop_id"
        case title = "title"
        case eventTitle = "event_title"
        case content = "content"
        case userId = "user_id"
        case nickname = "nickname"
        case thumbnail = "thumbnail"
        case hit = "hit"
        case ip = "ip"
        case startDate = "start_date"
        case endDate = "end_date"
        case commentCount = "comment_count"
        case isDeleted = "id_deleted"
    }
}
