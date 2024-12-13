//
//  BusAPI.swift
//  koin
//
//  Created by JOOMINKYUNG on 7/23/24.
//

import Alamofire

enum BusAPI {
    case fetchBusInformationList(FetchBusInformationListRequest)
    case searchBusInformation(SearchBusInfoRequest)
    case fetchBusTimetableList(FetchBusTimetableRequest)
    case fetchCityBusTimetableList(FetchCityBusTimetableRequest)
    case fetchShuttleBusTimetableRoute
    case fetchShuttleBusTimetableList(String)
}

extension BusAPI: Router, URLRequestConvertible {
    
    public var baseURL: String {
        return Bundle.main.baseUrl
    }
    
    public var path: String {
        switch self {
        case .fetchBusInformationList: return "/bus"
        case .searchBusInformation: return "/bus/search"
        case .fetchBusTimetableList: return "/bus/timetable/v2"
        case .fetchCityBusTimetableList: return "/bus/timetable/city"
        case .fetchShuttleBusTimetableRoute: return "/bus/courses/shuttle"
        case let .fetchShuttleBusTimetableList(id): return "/bus/timetable/shuttle/\(id)"
        }
    }
    
    public var method: Alamofire.HTTPMethod {
        switch self {
        default: return .get
        }
    }
    
    public var headers: [String: String] {
        switch self {
        default: return [:]
        }
    }
    
    
    public var parameters: Any? {
        switch self {
        case .fetchBusInformationList(let request):
            return try? request.toDictionary()
        case .searchBusInformation(let request):
            return try? request.toDictionary()
        case .fetchBusTimetableList(let request):
            return try? request.toDictionary()
        case .fetchShuttleBusTimetableRoute:
            return nil
        case .fetchCityBusTimetableList(let request):
            return try? request.toDictionary()
        case .fetchShuttleBusTimetableList(let id):
            return try? id.toDictionary()
        }
    }
    
    public var encoding: ParameterEncoding? {
        switch self {
        case .fetchShuttleBusTimetableRoute: return nil
        default: return URLEncoding.default
        }
    }
 
}

