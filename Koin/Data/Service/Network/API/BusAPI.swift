//
//  BusAPI.swift
//  koin
//
//  Created by JOOMINKYUNG on 7/23/24.
//

import Alamofire

enum BusAPI {
    case searchBusInformation(SearchBusInfoRequest)
    case fetchBusTimetableList(FetchBusTimetableRequest)
    case fetchCityBusTimetableList(FetchCityBusTimetableRequest)
    case fetchShuttleBusTimetableRoute
    case fetchShuttleBusTimetableList(String)
    case fetchEmergencyNotice
}

extension BusAPI: Router, URLRequestConvertible {
    
    public var baseURL: String {
        return Bundle.main.baseUrl
    }
    
    public var path: String {
        switch self {
        case .searchBusInformation: return "/bus/route"
        case .fetchBusTimetableList: return "/bus/timetable/v2"
        case .fetchCityBusTimetableList: return "/bus/timetable/city"
        case .fetchShuttleBusTimetableRoute: return "/bus/courses/shuttle"
        case let .fetchShuttleBusTimetableList(id): return "/bus/timetable/shuttle/\(id)"
        case .fetchEmergencyNotice: return "/bus/notice"
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
        case .searchBusInformation(let request):
            return try? request.toDictionary()
        case .fetchBusTimetableList(let request):
            return try? request.toDictionary()
        case .fetchShuttleBusTimetableRoute, .fetchEmergencyNotice:
            return nil
        case .fetchCityBusTimetableList(let request):
            return try? request.toDictionary()
        case .fetchShuttleBusTimetableList(let id):
            return try? id.toDictionary()
        }
    }
    
    public var encoding: ParameterEncoding? {
        switch self {
        case .fetchShuttleBusTimetableRoute, .fetchEmergencyNotice: return nil
        default: return URLEncoding.default
        }
    }
 
}

