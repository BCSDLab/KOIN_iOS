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
}

extension RecruitAPI: Router, URLRequestConvertible {

    public var baseURL: String {
        return Bundle.main.baseUrl
    }

    public var path: String {
        switch self {
        case .fetchList: return "/team-recruitments"
        }
    }

    public var method: Alamofire.HTTPMethod {
        switch self {
        case .fetchList: return .get
        }
    }

    public var headers: [String: String] {
        let baseHeaders: [String: String] = [:]
        switch self {
        case .fetchList:
            break
        }
        return baseHeaders
    }

    public var parameters: Any? {
        switch self {
        case .fetchList(let request):
            return try? request.toDictionary()
        }
    }

    public var encoding: ParameterEncoding? {
        switch self {
        case .fetchList:
            return URLEncoding(arrayEncoding: .noBrackets)
        }
    }
}
