//
//  UserRequest.swift
//  dev_koin
//
//  Created by 정태훈 on 2019/12/22.
//  Copyright © 2019 정태훈. All rights reserved.
//

import Foundation
import UIKit
import SwiftUI

struct UserData: Codable {
    let token: String?
    let ttl: Int?
    var user: User?
    private enum CodingKeys: String, CodingKey {
        case token = "token"
        case ttl = "ttl"
        case user = "user"
    }
}
