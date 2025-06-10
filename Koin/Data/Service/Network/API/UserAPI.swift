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
    case checkDuplicatedPhoneNumber(CheckDuplicatedPhoneNumberRequest)
    case checkDuplicatedNickname(CheckDuplicatedNicknameRequest)
    case login(LoginRequest)
    case fetchUserData
    case checkPassword(CheckPasswordRequest)
    case modify(UserPutRequest)
    case refreshToken(RefreshTokenRequest)
    case revoke
    case checkAuth
    case checkLogin
    case sendVerificationCode(SendVerificationCodeRequest)
    case checkVerificationCode(CheckVerificationCodeRequest)
    case checkDuplicatedId(CheckDuplicatedIdRequest)
    case studentRegisterForm(StudentRegisterFormRequest)
    case generalRegisterForm(GeneralRegisterFormRequest)
}

extension UserAPI: Router, URLRequestConvertible {
    
    public var baseURL: String {
        return Bundle.main.baseUrl
    }
    
    public var path: String {
        switch self {
        case .findPassword: return "/user/find/password"
        case .register: return "/user/student/register"
        case .checkDuplicatedPhoneNumber: return "/user/check/phone"
        case .checkDuplicatedNickname: return "/user/check/nickname"
        case .login: return "/v2/users/login"
        case .fetchUserData, .modify: return "/user/student/me"
        case .checkPassword: return "/user/check/password"
        case .revoke: return "/user"
        case .refreshToken: return "/user/refresh"
        case .checkAuth: return "/user/auth"
        case .checkLogin: return "/user/check/login"
        case .sendVerificationCode: return "/users/verification/sms/send"
        case .checkVerificationCode: return "/users/verification/sms/verify"
        case .checkDuplicatedId: return "/user/check/id"
        case .studentRegisterForm: return "/v2/users/students/register"
        case .generalRegisterForm: return "/v2/users/register"
        }
    }
    
    public var method: Alamofire.HTTPMethod {
        switch self {
        case .findPassword, .register, .login, .checkPassword, .refreshToken, .sendVerificationCode, .checkVerificationCode, .studentRegisterForm, .generalRegisterForm: return .post
        case .checkDuplicatedPhoneNumber, .checkDuplicatedNickname, .fetchUserData, .checkAuth, .checkLogin, .checkDuplicatedId: return .get
        case .modify: return .put
        case .revoke: return .delete
        }
    }
    
    public var headers: [String: String] {
        var baseHeaders: [String: String] = [:]
        
        switch self {
        case .findPassword, .register, .checkDuplicatedPhoneNumber, .checkDuplicatedNickname, .login, .checkPassword, .modify, .refreshToken, .sendVerificationCode, .checkVerificationCode, .checkDuplicatedId, .studentRegisterForm, .generalRegisterForm:
            baseHeaders["Content-Type"] = "application/json"
        case .fetchUserData, .revoke, .checkAuth, .checkLogin:
            break
        }
        switch self {
        case .fetchUserData, .revoke, .modify, .checkPassword, .checkAuth :
            if let token = KeychainWorker.shared.read(key: .access) {
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
        case .checkDuplicatedPhoneNumber(let request):
            return try? request.toDictionary()
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
        case .checkLogin:
            return ["accessToken": KeychainWorker.shared.read(key: .access) ?? ""]
        case .sendVerificationCode(let request):
            return try? JSONEncoder().encode(request)
        case .checkVerificationCode(let request):
            return try? JSONEncoder().encode(request)
        case .checkDuplicatedId(let request):
            return try? request.toDictionary()
        case .studentRegisterForm(let request):
            return try? JSONEncoder().encode(request)
        case .generalRegisterForm(let request):
            return try? JSONEncoder().encode(request)
        }
    }
    
    public var encoding: Alamofire.ParameterEncoding? {
        switch self {
        case .findPassword, .register, .login, .checkPassword, .modify, .sendVerificationCode, .checkVerificationCode, .studentRegisterForm, .generalRegisterForm: return JSONEncoding.default
        case .checkDuplicatedPhoneNumber, .checkDuplicatedNickname, .fetchUserData, .checkAuth, .checkDuplicatedId: return URLEncoding.default
        case .checkLogin: return URLEncoding.queryString
        case .revoke, .refreshToken: return nil
        }
    }
}
