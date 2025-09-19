//
//  ShuttleBusTimetableDTO.swift
//  koin
//
//  Created by JOOMINKYUNG on 12/8/24.
//

import Foundation

// MARK: - ShuttleBusTimetableInfo
struct ShuttleBusTimetableDTO: Decodable {
    let id, region, routeName: String
    let routeType: ShuttleRouteType
    let subName: String?
    let nodeInfo: [NodeInfo]
    let routeInfo: [RouteInfo]

    enum CodingKeys: String, CodingKey {
        case id, region
        case routeType = "route_type"
        case routeName = "route_name"
        case subName = "sub_name"
        case nodeInfo = "node_info"
        case routeInfo = "route_info"
    }
}

// MARK: - NodeInfo
struct NodeInfo: Decodable {
    let name: String
    let detail: String?
}

// MARK: - RouteInfo
struct RouteInfo: Decodable {
    let name: String
    let detail: String?
    let arrivalTime: [String?]

    enum CodingKeys: String, CodingKey {
        case name, detail
        case arrivalTime = "arrival_time"
    }
}

extension ShuttleBusTimetableDTO {
    func toDomain() -> ShuttleBusTimetableDTO {
        let hasGoSchool = routeInfo.contains { $0.name == "등교" }
        let hasDropOffSchool = routeInfo.contains { $0.name == "하교" }

        let updatedRouteInfo = routeInfo.map { route in
            if route.name == "하교" && hasGoSchool && hasDropOffSchool {
                return route.toDomain()
            } else {
                return route
            }
        }

        return ShuttleBusTimetableDTO(
            id: id,
            region: region,
            routeName: routeName,
            routeType: routeType,
            subName: subName,
            nodeInfo: nodeInfo,
            routeInfo: updatedRouteInfo
        )
    }
}

extension RouteInfo {
    func toDomain() -> RouteInfo {
        return RouteInfo(
            name: name,
            detail: detail,
            arrivalTime: name == "하교" ? arrivalTime.reversed() : arrivalTime
        )
    }
}
