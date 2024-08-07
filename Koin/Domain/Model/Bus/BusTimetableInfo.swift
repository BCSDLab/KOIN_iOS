//
//  BusCourse.swift
//  koin
//
//  Created by JOOMINKYUNG on 7/27/24.
//

import Foundation

struct BusTimetableInfo {
    var courseName: String
    let routeName: String
    let arrivalInfos: [BusArrivalInfo]
    let updatedAt: String
}

struct BusArrivalInfo {
    let leftNode: String?
    let rightNode: String?
}
