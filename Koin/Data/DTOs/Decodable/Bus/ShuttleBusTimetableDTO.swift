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
    let arrivalTime: [String?]

    enum CodingKeys: String, CodingKey {
        case name
        case arrivalTime = "arrival_time"
    }
}

extension ShuttleBusTimetableDTO {
    func toDomain() -> ShuttleBusTimetableDTO {
        if routeInfo.count > 1 && routeInfo[1].name == "하교" {
            return ShuttleBusTimetableDTO(id: id, region: region, routeName: routeName, routeType: routeType, subName: subName, nodeInfo: nodeInfo.reversed(), routeInfo: routeInfo.map { $0.toDomain() })
        }
        else {
            return self
        }
    }
}

extension RouteInfo {
    func toDomain() -> RouteInfo {
        if name == "하교" {
            return RouteInfo(name: name, arrivalTime: arrivalTime.reversed())
        }
        else {
            return self
        }
    }
}
