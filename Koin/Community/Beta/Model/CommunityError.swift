//
//  CommunityError.swift
//  Koin
//
//  Created by 정태훈 on 2020/04/05.
//  Copyright © 2020 정태훈. All rights reserved.
//

import Foundation

enum KoinCommunityError: Error {
    case parsing(description: String)
    case network(description: String)
}
