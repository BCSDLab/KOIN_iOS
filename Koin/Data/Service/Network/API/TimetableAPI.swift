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
    case deleteLecture(frameId: Int, lectureId: Int)
    case deleteSemester(semester: String)
    case _deleteLecture(id: Int)
    case rollbackFrame(id: Int)
    case fetchAllFrames
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
        case .deleteLecture(frameId: let frameId, lectureId: let lectureId): return "/v2/timetables/frame/\(frameId)/lecture/\(lectureId)"
        case ._deleteLecture(let id): return "/v2/timetables/lecture/\(id)"
        case .deleteSemester: return "/v2/all/timetables/frame"
        case .rollbackFrame: return "/v2/timetables/frame/rollback"
        case .fetchAllFrames: return "/v2/timetables/frames"
        }
    }
    
    public var method: Alamofire.HTTPMethod {
        switch self {
        case .fetchDeptList, .fetchFrame, .fetchLecture, .fetchMySemester, .fetchLectureList, .fetchSemester, .fetchAllFrames: return .get
        case .deleteFrame, .deleteLecture, .deleteSemester, ._deleteLecture : return .delete
        case .createFrame, .postLecture, .rollbackFrame: return .post
        case .modifyFrame, .modifyLecture: return .put
        }
    }
    
    public var headers: [String: String] {
        var baseHeaders: [String: String] = [:]
        switch self {
        case .fetchFrame, .deleteFrame, .createFrame, .modifyFrame, .postLecture, .modifyLecture, .fetchLecture, .fetchMySemester, .deleteLecture, .deleteSemester, ._deleteLecture, .rollbackFrame, .fetchAllFrames:
            if let token = KeychainWorker.shared.read(key: .access) {
                baseHeaders["Authorization"] = "Bearer \(token)"
            }
        default: break
        }
        switch self {
        case .createFrame, .modifyFrame, .postLecture, .modifyLecture, .rollbackFrame:
            baseHeaders["Content-Type"] = "application/json"
        default:
            break
        }
        return baseHeaders
    }
    
    public var parameters: Any? {
        switch self {
        case .fetchDeptList, .fetchSemester, .fetchMySemester, .deleteLecture, ._deleteLecture, .fetchAllFrames: return nil
        case .fetchLectureList(let semester):
            return ["semester_date": semester]
        case .fetchFrame(let semester):
            return ["semester": semester] // Query parameter
        case .deleteFrame(let id):
            return ["id": id]
        case .createFrame(let semester):
            return ["semester": semester]
        case .modifyFrame(let frame):
            return ["timetable_name": frame.timetableName, "is_main": frame.isMain]
        case .fetchLecture(let id):
            return ["timetable_frame_id": id]
        case let .postLecture(request): return try? request.toDictionary()
        case let .modifyLecture(request): return try? request.toDictionary()
        case let .deleteSemester(semester): return ["semester": semester]
        case let .rollbackFrame(id): return ["timetable_frame_id": id]
        }
    }
    
    public var encoding: ParameterEncoding? {
        switch self {
        case .fetchDeptList, .fetchSemester, .fetchMySemester, .deleteLecture, ._deleteLecture, .fetchAllFrames: return URLEncoding.default
        case .fetchFrame, .fetchLecture, .fetchLectureList, .rollbackFrame: return URLEncoding.queryString
        case .deleteFrame, .deleteSemester: return URLEncoding.queryString
        case .createFrame, .modifyFrame, .postLecture, .modifyLecture: return JSONEncoding.default
        }
    }
    
}
