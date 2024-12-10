//
//  ShuttleTimetableInfo.swift
//  koin
//
//  Created by JOOMINKYUNG on 11/30/24.
//

import Foundation

struct ShuttleTimetableInfos {
    let region: String
    let routes: [ShuttleTimetableInfo]
}

struct ShuttleTimetableInfo {
    let routeType: ShuttleRouteType
    let routeName: String
}
