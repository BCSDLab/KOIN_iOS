//
//  Department.swift
//  koin
//
//  Created by 홍기정 on 7/18/26.
//

import Foundation

struct Department: Identifiable {
    var id: Int
    let name: String
    let tasks: [DepartmentTask]
}
