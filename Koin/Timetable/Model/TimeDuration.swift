//
//  TimeDuration.swift
//  Koin
//
//  Created by 정태훈 on 2020/08/26.
//  Copyright © 2020 정태훈. All rights reserved.
//

import Foundation

struct TimeDuration {
    let start: Int
    let end: Int
}

extension TimeDuration: Hashable {
    static func == (lhs: TimeDuration, rhs: TimeDuration) -> Bool {
        return lhs.start == rhs.start
    }
    func hash(into hasher: inout Hasher) {
        hasher.combine(self.start)
    }
}
