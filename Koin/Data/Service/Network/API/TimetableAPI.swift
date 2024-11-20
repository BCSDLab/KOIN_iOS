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
    case fetchLecture(frameId: Int)
    case modifyLecture(request: LectureRequest)
    case postLecture(request: LectureRequest)
    case fetchMySemester
    case fetchLectureList(semester: String)
    case fetchSemester
}

extension TimetableAPI: Router, URLRequestConvertible {
    
    public var baseURL: String {
        return Bundle.main.baseUrl
    }
    
    public var path: String {
        switch self {
        case .fetchDeptList: return "/depts"
        case .fetchFrame: return "/v2/timetables/frames"
        case .deleteFrame: return "/v2/timetables/frame"
        case .createFrame: return "/v2/timetables/frame"
        case .modifyFrame(let frame): return "/v2/timetables/frame/\(frame.id)"
        case .fetchLecture, .modifyLecture, .postLecture :  return "/v2/timetables/lecture"
        case .fetchMySemester: return "/semesters/check"
        case .fetchLectureList: return "/lectures"
        case .fetchSemester: return "/semesters"
        }
    }
    
    public var method: Alamofire.HTTPMethod {
        switch self {
        case .fetchDeptList, .fetchFrame, .fetchLecture, .fetchMySemester, .fetchLectureList, .fetchSemester: return .get
        case .deleteFrame: return .delete
        case .createFrame, .postLecture: return .post
        case .modifyFrame, .modifyLecture: return .put
        }
    }
    
    public var headers: [String: String] {
        var baseHeaders: [String: String] = [:]
        switch self {
        case .fetchFrame, .deleteFrame, .createFrame, .modifyFrame, .postLecture, .modifyLecture, .fetchLecture, .fetchMySemester:
            if let token = KeyChainWorker.shared.read(key: .access) {
                baseHeaders["Authorization"] = "Bearer \(token)"
            }
        default: break
        }
        switch self {
        case .createFrame, .modifyFrame, .postLecture, .modifyLecture:
            baseHeaders["Content-Type"] = "application/json"
        default:
            break
        }
        return baseHeaders
    }
    
    public var parameters: Any? {
        switch self {
        case .fetchDeptList, .fetchSemester, .fetchMySemester: return nil
        case .fetchLectureList(let semester):
            return ["semester_date": semester]
        case .fetchFrame(let semester):
            return ["semester": semester] // Query parameter
        case .deleteFrame(let id):
            return ["id": id]
        case .createFrame(let semester):
            return ["semester": semester, "timetable_name": "시간표 1"]
        case .modifyFrame(let frame):
            return ["timetable_name": frame.timetableName, "is_main": frame.isMain]
        case .fetchLecture(let id):
            return ["timetable_frame_id": id]
        case let .postLecture(request): return try? request.toDictionary()
        case let .modifyLecture(request): return try? request.toDictionary()
        }
    }
    
    public var encoding: ParameterEncoding? {
        switch self {
        case .fetchDeptList, .fetchSemester, .fetchMySemester: return URLEncoding.default
        case .fetchFrame, .fetchLecture, .fetchLectureList: return URLEncoding.queryString
        case .deleteFrame: return URLEncoding.queryString
        case .createFrame, .modifyFrame, .postLecture, .modifyLecture: return JSONEncoding.default
        }
    }
    
}
