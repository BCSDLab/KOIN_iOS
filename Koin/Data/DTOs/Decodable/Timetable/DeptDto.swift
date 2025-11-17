//
//  DeptDto.swift
//  koin
//
//  Created by 김나훈 on 3/20/24.
//

import Foundation

struct DeptDto: Decodable {
    let curriculumLink: String
    let deptNums: [String]
    let name: String
    enum CodingKeys: String, CodingKey {
        case curriculumLink = "curriculum_link"
        case deptNums = "dept_nums"
        case name
    }
}
