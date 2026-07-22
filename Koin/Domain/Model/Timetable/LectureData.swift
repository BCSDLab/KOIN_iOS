//
//  LectureData.swift
//  koin
//
//  Created by 김나훈 on 11/20/24.
//

import Foundation

struct LectureData: Hashable {
    let id: Int
    let name: String
    let professor: String
    var classTime: [Int]
    let grades: String
}
