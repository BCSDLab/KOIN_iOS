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
        }
    }

    public var method: Alamofire.HTTPMethod {
        switch self {
        case .fetchList: return .get
        case .fetchData: return .get
        case .deleteData: return .delete
        }
    }

    public var headers: [String: String] {
        let baseHeaders: [String: String] = [:]
        switch self {
        case .fetchList, .fetchData, .deleteData:
            break
        }
        return baseHeaders
    }

    public var parameters: Any? {
        switch self {
        case .fetchList(let request):
            return try? request.toDictionary()
        case .fetchData, .deleteData:
            return nil
        }
    }

    public var encoding: ParameterEncoding? {
        switch self {
        case .fetchList:
            return URLEncoding(arrayEncoding: .noBrackets)
        case .fetchData, .deleteData:
            return nil
        }
    }
}
