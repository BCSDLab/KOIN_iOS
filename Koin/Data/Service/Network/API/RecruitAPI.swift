//
//  RecruitAPI.swift
//  koin
//
//  Created by 홍기정 on 10/1/26.
//

import Foundation
import Alamofire

enum RecruitAPI {
    case fetchList(RecruitListRequestDto)
    case fetchData(Int)
    case deleteData(Int)
    case post(RecruitPostRequestDto)
    case modify(Int, RecruitPostRequestDto)
    case fetchMyProfile
    case upsertMyProfile(RecruitProfileRequestDto)
}

extension RecruitAPI: Router, URLRequestConvertible {

    public var baseURL: String {
        return Bundle.main.baseUrl
    }

    public var path: String {
        switch self {
        case .fetchList: return "/team-recruitments"
        case .fetchData(let id): return "/team-recruitments/\(id)"
        case .deleteData(let id): return "/team-recruitments/\(id)"
        case .post: return "/team-recruitments"
        case .modify(let id, _): return "/team-recruitments/\(id)"
        case .fetchMyProfile: return "/team-recruitment-profiles/me"
        case .upsertMyProfile: return "/team-recruitment-profiles/me"
        }
    }

    public var method: Alamofire.HTTPMethod {
        switch self {
        case .fetchList: return .get
        case .fetchData: return .get
        case .deleteData: return .delete
        case .post: return .post
        case .modify: return .put
        case .fetchMyProfile: return .get
        case .upsertMyProfile: return .put
        }
    }

    public var headers: [String: String] {
        var baseHeaders: [String: String] = [:]
        switch self {
        case .fetchList, .fetchData, .deleteData, .fetchMyProfile:
            break
        case .post, .modify, .upsertMyProfile:
            baseHeaders["Content-Type"] = "application/json"
        }
        return baseHeaders
    }

    public var parameters: Any? {
        switch self {
        case .fetchList(let request):
            return try? request.toDictionary()
        case .fetchData, .deleteData, .fetchMyProfile:
            return nil
        case .post(let request), .modify(_, let request):
            return try? request.toDictionary()
        case .upsertMyProfile(let request):
            return try? request.toDictionary()
        }
    }

    public var encoding: ParameterEncoding? {
        switch self {
        case .fetchList:
            return URLEncoding(arrayEncoding: .noBrackets)
        case .fetchData, .deleteData, .fetchMyProfile:
            return nil
        case .post, .modify, .upsertMyProfile:
            return JSONEncoding.default
        }
    }
}
