//
//  UserError.swift
//  Koin
//
//  Created by 정태훈 on 2020/05/13.
//  Copyright © 2020 정태훈. All rights reserved.
//

import Foundation

enum UserError: Error {
    case parsing(description: String)
    case network(description: String)
    case user(description: String)
}
