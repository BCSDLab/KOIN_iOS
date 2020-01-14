//
// Created by 정태훈 on 2020/01/13.
// Copyright (c) 2020 정태훈. All rights reserved.
//

import Foundation
import Combine

struct Shops: Codable {

    let shops: [Store]

    private enum CodingKeys: String, CodingKey {
        case shops = "shops"
    }
}