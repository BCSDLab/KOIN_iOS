//
//  ShuttleRouteDto.swift
//  koin
//
//  Created by JOOMINKYUNG on 12/8/24.
//

import Foundation

// MARK: - ShuttleRouteDto
struct ShuttleRouteDto: Decodable {
    let routeRegions: [RouteRegion]
    let semesterInfo: SemesterInfo

    enum CodingKeys: String, CodingKey {
        case routeRegions = "route_regions"
        case semesterInfo = "semester_info"
    }
}

// MARK: - RouteRegion
struct RouteRegion: Decodable {
    let region: String
    let routes: [Route]
}

// MARK: - Route
struct Route: Decodable {
    let id, routeName: String
    let type: ShuttleRouteType
    let subName: String?

    enum CodingKeys: String, CodingKey {
        case id, type
        case routeName = "route_name"
        case subName = "sub_name"
    }
}

// MARK: - SemesterInfo
struct SemesterInfo: Decodable {
    let name, from, to: String
}
