//
//  TimetableAPI.swift
//  koin
//
//  Created by 김나훈 on 7/22/24.
//

import Alamofire

enum TimetableAPI {
    case fetchDeptList
    case fetchFrame(semester: String)
    case deleteFrame(id: Int)
    case createFrame(semester: String)
    case modifyFrame(frame: FrameDTO)
}

extension TimetableAPI: Router, URLRequestConvertible {
    
    public var baseURL: String {
        return Bundle.main.baseUrl
    }
    
    public var path: String {
        switch self {
        case .fetchDeptList: return "/depts"
        case .fetchFrame: return "/v2/timetables/frames"
        case .deleteFrame(let id): return "/v2/timetables/frame"
        case .createFrame: return "/v2/timetables/frame"
        case .modifyFrame(let frame): return "/v2/timetables/frame/\(frame.id)"
        }
    }
    
    public var method: Alamofire.HTTPMethod {
        switch self {
        case .fetchDeptList, .fetchFrame: return .get
        case .deleteFrame: return .delete
        case .createFrame: return .post
        case .modifyFrame: return .put
        }
    }
    
    public var headers: [String: String] {
        var baseHeaders: [String: String] = [:]
        switch self {
        case .fetchFrame, .deleteFrame, .createFrame, .modifyFrame:
            if let token = KeyChainWorker.shared.read(key: .access) {
                baseHeaders["Authorization"] = "Bearer \(token)"
            }
        default: break
        }
        switch self {
        case .createFrame, .modifyFrame:
            baseHeaders["Content-Type"] = "application/json"
        default:
            break
        }
        return baseHeaders
    }
    
    public var parameters: Any? {
        switch self {
        case .fetchDeptList: return nil
        case .fetchFrame(let semester):
            return ["semester": semester] // Query parameter
        case .deleteFrame(let id):
            return ["id": id]
        case .createFrame(let semester):
            return ["semester": semester, "timetable_name": "시간표 1"]
        case .modifyFrame(let frame):
            return ["timetable_name": frame.timetableName, "is_main": frame.isMain]
        }
    }
    
    public var encoding: ParameterEncoding? {
        switch self {
        case .fetchDeptList: return URLEncoding.default
        case .fetchFrame: return URLEncoding.queryString
        case .deleteFrame: return URLEncoding.queryString
        case .createFrame, .modifyFrame: return JSONEncoding.default
        }
    }
    
}
