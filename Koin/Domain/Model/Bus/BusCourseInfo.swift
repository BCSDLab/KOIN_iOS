//
//  BusCourseList.swift
//  koin
//
//  Created by JOOMINKYUNG on 7/28/24.
//

import Foundation

struct BusCourseInfo {
    let busCourse: String
    let busType: BusType
    let direction: BusDirection
    let region: String
}

struct CityBusCourseInfo {
    let busNumber: BusNumber
    let busCourse: String
    let busNode: CityBusDirection
}
