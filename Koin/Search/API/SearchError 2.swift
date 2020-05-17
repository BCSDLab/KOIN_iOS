//
//  SearchError.swift
//  Koin
//
//  Created by 정태훈 on 2020/05/01.
//  Copyright © 2020 정태훈. All rights reserved.
//

import Foundation

enum SearchError: Error {
    case parsing(description: String)
    case network(description: String)
}
