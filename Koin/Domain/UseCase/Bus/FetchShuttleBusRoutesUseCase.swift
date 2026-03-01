//
//  FetchShuttleBusTimetableUseCase.swift
//  koin
//
//  Created by JOOMINKYUNG on 7/27/24.
//

import Combine

protocol FetchShuttleBusRoutesUseCase {
    func execute(busRouteType: ShuttleRouteType) -> AnyPublisher<ShuttleRouteDto, Error>
}

final class DefaultFetchShuttleBusRoutesUseCase: FetchShuttleBusRoutesUseCase {
    let busRepository: BusRepository
    
    init(busRepository: BusRepository) {
        self.busRepository = busRepository
    }
    
    func execute(busRouteType: ShuttleRouteType) -> AnyPublisher<ShuttleRouteDto, Error> {
        return busRepository.fetchShuttleRouteList().map { [weak self] routeList in
            return self?.filterByShuttleRouteType(busTimetableInfo: routeList, shuttleRouteType: busRouteType) ?? ShuttleRouteDto(routeRegions: [], semesterInfo: SemesterInfo(name: "", from: "", to: ""))
        }.eraseToAnyPublisher()
    }

    private func filterByShuttleRouteType(busTimetableInfo: ShuttleRouteDto, shuttleRouteType: ShuttleRouteType) -> ShuttleRouteDto {
        if shuttleRouteType == .overall {
            return busTimetableInfo
        }
        
        let filteredRegions = busTimetableInfo.routeRegions.map { region in
            let filteredRoutes = region.routes.filter { route in
                route.type == shuttleRouteType
            }
            
            return RouteRegion(region: region.region, routes: filteredRoutes)
        }.filter { !$0.routes.isEmpty }
        
        return ShuttleRouteDto(routeRegions: filteredRegions, semesterInfo: busTimetableInfo.semesterInfo)
    }
}
