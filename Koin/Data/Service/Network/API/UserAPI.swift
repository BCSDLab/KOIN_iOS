//
//  UserAPI.swift
//  koin
//
//  Created by 김나훈 on 7/22/24.
//
import Alamofire

enum UserAPI {
    case findPassword(FindPasswordRequest)
    case register(UserRegisterRequest)
    case checkDuplicatedNickname(CheckDuplicatedNicknameRequest)
    case login(LoginRequest)
    case fetchUserData
    case checkPassword(CheckPasswordRequest)
    case modify(UserPutRequest)
    case refreshToken(RefreshTokenRequest)
    case revoke
    case checkAuth
}

extension UserAPI: Router, URLRequestConvertible {
    
    public var baseURL: String {
        return Bundle.main.baseUrl
    }
    
    public var path: String {
        switch self {
        case .findPassword: return "/user/find/password"
        case .register: return "/user/student/register"
        case .checkDuplicatedNickname: return "/user/check/nickname"
        case .login: return "/student/login"
        case .fetchUserData, .modify: return "/user/student/me"
        case .checkPassword: return "/user/check/password"
        case .revoke: return "/user"
        case .refreshToken: return "/user/refresh"
        case .checkAuth: return "/user/auth"
        }
    }
    
    public var method: Alamofire.HTTPMethod {
        switch self {
        case .findPassword, .register, .login, .checkPassword, .refreshToken: return .post
        case .checkDuplicatedNickname, .fetchUserData, .checkAuth: return .get
        case .modify: return .put
        case .revoke: return .delete
        }
    }
    
    public var headers: [String: String] {
        var baseHeaders: [String: String] = [:]
        
        switch self {
        case .findPassword, .register, .checkDuplicatedNickname, .login, .checkPassword, .modify, .refreshToken:
            baseHeaders["Content-Type"] = "application/json"
        case .fetchUserData, .revoke, .checkAuth:
            break
        }
        switch self {
        case .fetchUserData, .revoke, .modify, .checkPassword, .checkAuth :
            if let token = KeyChainWorker.shared.read(key: .access) {
                baseHeaders["Authorization"] = "Bearer \(token)"
            }
        default: break
        }
        
        
        return baseHeaders
    }
    
    public var parameters: Any? {
        switch self {
        case .findPassword(let request):
            return try? JSONEncoder().encode(request)
        case .register(let request):
            return try? JSONEncoder().encode(request)
        case .login(let request):
            return try? JSONEncoder().encode(request)
        case .checkDuplicatedNickname(let request):
            return try? request.toDictionary()
        case .fetchUserData:
            return nil
        case .checkPassword(let request):
            return try? JSONEncoder().encode(request)
        case .modify(let request):
            return try? JSONEncoder().encode(request)
        case .revoke:
            return nil
        case .refreshToken(let request):
            return try? JSONEncoder().encode(request)
        case .checkAuth:
            return nil
        }
    }
    
    public var encoding: Alamofire.ParameterEncoding? {
        switch self {
        case .findPassword, .register, .login, .checkPassword, .modify: return JSONEncoding.default
        case .checkDuplicatedNickname, .fetchUserData, .checkAuth: return URLEncoding.default
        case .revoke, .refreshToken: return nil
        }
    }
}
