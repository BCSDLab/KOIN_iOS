//
//  ShuttleBusTimetable.swift
//  koin
//
//  Created by 이은지 on 9/19/25.
//

import Foundation

struct ShuttleBusTimetable {
    let id: String
    let region: String
    let routeName: String
    let routeType: ShuttleRouteType
    let subName: String?
    let nodeInfo: [NodeInfo]
    let routeInfo: [RouteInfo]
}

struct NodeInfo {
    let name: String
    let detail: String?
}

struct RouteInfo {
    let name: String
    let detail: String?
    let arrivalTime: [String?]
}
