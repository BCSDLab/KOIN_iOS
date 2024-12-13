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
        }
    }
    
    public var method: Alamofire.HTTPMethod {
        switch self {
        case .fetchBusInformationList: return .get
        case .searchBusInformation: return .get
        case .fetchBusTimetableList: return .get
        case .fetchCityBusTimetableList: return .get
        case .fetchShuttleBusTimetableRoute: return .get
        }
    }
    
    public var headers: [String: String] {
        switch self {
        case .fetchBusInformationList: return [:]
        case .searchBusInformation: return [:]
        case .fetchBusTimetableList: return [:]
        case .fetchCityBusTimetableList: return [:]
        case .fetchShuttleBusTimetableRoute: return [:]
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
        }
    }
    
    public var encoding: ParameterEncoding? {
        switch self {
        case .fetchBusInformationList: return URLEncoding.default
        case .searchBusInformation: return URLEncoding.default
        case .fetchBusTimetableList: return URLEncoding.default
        case .fetchShuttleBusTimetableRoute: return nil
        case .fetchCityBusTimetableList: return URLEncoding.default
        }
    }
 
}

