//
//  ShuttleBusTimetableDto.swift
//  koin
//
//  Created by JOOMINKYUNG on 12/8/24.
//

import Foundation

struct ShuttleBusTimetableDto: Decodable {
    let id, region, routeName: String
    let routeType: ShuttleRouteType
    let subName: String?
    let nodeInfo: [NodeInfoDto]
    let routeInfo: [RouteInfoDto]

    enum CodingKeys: String, CodingKey {
        case id, region
        case routeType = "route_type"
        case routeName = "route_name"
        case subName = "sub_name"
        case nodeInfo = "node_info"
        case routeInfo = "route_info"
    }
}

struct NodeInfoDto: Decodable {
    let name: String
    let detail: String?
}

struct RouteInfoDto: Decodable {
    let name: String
    let detail: String?
    let arrivalTime: [String?]

    enum CodingKeys: String, CodingKey {
        case name, detail
        case arrivalTime = "arrival_time"
    }
}

extension ShuttleBusTimetableDto {
    func toDomain() -> ShuttleBusTimetable {
        let hasGoSchool = routeInfo.contains { $0.name == "등교" }
        let hasDropOffSchool = routeInfo.contains { $0.name == "하교" }

        let updatedRouteInfo = routeInfo.map { dto in
            dto.toDomain(hasGoSchool: hasGoSchool, hasDropOffSchool: hasDropOffSchool)
        }

        return ShuttleBusTimetable(
            id: id,
            region: region,
            routeName: routeName,
            routeType: routeType,
            subName: subName,
            nodeInfo: nodeInfo.map { $0.toDomain() },
            routeInfo: updatedRouteInfo
        )
    }
}

extension NodeInfoDto {
    func toDomain() -> NodeInfo {
        NodeInfo(name: name, detail: detail)
    }
}

extension RouteInfoDto {
    func toDomain(hasGoSchool: Bool, hasDropOffSchool: Bool) -> RouteInfo {
        let reversedArrival = (name == "하교" && hasGoSchool && hasDropOffSchool)
            ? arrivalTime.reversed()
            : arrivalTime

        return RouteInfo(
            name: name,
            detail: detail,
            arrivalTime: Array(reversedArrival)
        )
    }
}
