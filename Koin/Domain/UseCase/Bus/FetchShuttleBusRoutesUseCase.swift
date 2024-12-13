//
//  FetchShuttleBusTimetableUseCase.swift
//  koin
//
//  Created by JOOMINKYUNG on 7/27/24.
//

import Combine

protocol FetchShuttleBusRoutesUseCase {
    func execute(busRouteType: ShuttleRouteType) -> AnyPublisher<ShuttleRouteDTO, Error>
}

final class DefaultFetchShuttleBusRoutesUseCase: FetchShuttleBusRoutesUseCase {
    let busRepository: BusRepository
    
    init(busRepository: BusRepository) {
        self.busRepository = busRepository
    }
    
    func execute(busRouteType: ShuttleRouteType) -> AnyPublisher<ShuttleRouteDTO, Error> {
        return busRepository.fetchShuttleRouteList().map { [weak self] routeList in
            return self?.filterByShuttleRouteType(busTimetableInfo: routeList, shuttleRouteType: busRouteType) ?? ShuttleRouteDTO(routeRegions: [], semesterInfo: SemesterInfo(name: "", from: "", to: ""))
        }.eraseToAnyPublisher()
    }

    private func filterByShuttleRouteType(busTimetableInfo: ShuttleRouteDTO, shuttleRouteType: ShuttleRouteType) -> ShuttleRouteDTO {
        if shuttleRouteType == .overall {
            return busTimetableInfo
        }
        
        let filteredRegions = busTimetableInfo.routeRegions.map { region in
            let filteredRoutes = region.routes.filter { route in
                route.type == shuttleRouteType
            }
            
            return RouteRegion(region: region.region, routes: filteredRoutes)
        }.filter { !$0.routes.isEmpty }
        
        return ShuttleRouteDTO(routeRegions: filteredRegions, semesterInfo: busTimetableInfo.semesterInfo)
    }
}
