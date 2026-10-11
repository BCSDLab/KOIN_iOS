//
//  Array+.swift
//  koin
//
//  Created by 홍기정 on 8/29/26.
//

import Foundation

extension Array where Element: Equatable {
    mutating func removeDuplicates() {
        self = self.reduce(into: [Element]()) { array, item in
            if !array.contains(item) {
                array.append(item)
            }
        }
    }
}
