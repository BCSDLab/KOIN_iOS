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
    case fetchStudentUserData
    case fetchGeneralUserData
    case modifyStudentUserData(UserPutRequest)
    case modifyGeneralUserData(UserPutRequest)
    case checkPassword(CheckPasswordRequest)
    case refreshToken(RefreshTokenRequest)
    case revoke
    case checkAuth
    case checkLogin
    case sendVerificationCode(SendVerificationCodeRequest)
    case checkVerificationCode(CheckVerificationCodeRequest)
    case checkDuplicatedId(CheckDuplicatedIdRequest)
    case studentRegisterForm(StudentRegisterFormRequest)
    case generalRegisterForm(GeneralRegisterFormRequest)
    case sendVerificationEmail(SendVerificationEmailRequest)
    case checkVerificationEmail(CheckVerificationEmailRequest)
    case findIdSms(FindIdSmsRequest)
    case findIdEmail(FindIdEmailRequest)
    case resetPasswordSms(ResetPasswordSmsRequest)
    case resetPasswordEmail(ResetPasswordEmailRequest)
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
        case .fetchStudentUserData: return "/user/student/me"
        case .modifyStudentUserData: return "/v2/users/students/me"
        case .fetchGeneralUserData: return "/v2/users/me"
        case .modifyGeneralUserData: return "/v2/users/me"
        case .checkPassword: return "/user/check/password"
        case .revoke: return "/user"
        case .refreshToken: return "/user/refresh"
        case .checkAuth: return "/user/auth"
        case .checkLogin: return "/user/check/login"
        case .sendVerificationCode: return "/users/verification/sms/send"
        case .checkVerificationCode: return "/users/verification/sms/verify"
        case .sendVerificationEmail: return "/users/verification/email/send"
        case .checkVerificationEmail: return "/users/verification/email/verify"
        case .checkDuplicatedId: return "/user/check/id"
        case .studentRegisterForm: return "/v2/users/students/register"
        case .generalRegisterForm: return "/v2/users/register"
        case .findIdSms: return "/users/id/find/sms"
        case .findIdEmail: return "/users/id/find/email"
        case .resetPasswordSms: return "/users/password/reset/sms"
        case .resetPasswordEmail: return "/users/password/reset/email"
        }
    }
    
    public var method: Alamofire.HTTPMethod {
        switch self {
        case .findPassword, .register, .login, .checkPassword, .refreshToken, .sendVerificationCode, .checkVerificationCode, .studentRegisterForm, .generalRegisterForm, .sendVerificationEmail, .checkVerificationEmail, .findIdSms, .findIdEmail, .resetPasswordSms, .resetPasswordEmail: return .post
        case .checkDuplicatedPhoneNumber, .checkDuplicatedNickname, .fetchStudentUserData, .checkAuth, .checkLogin, .checkDuplicatedId, .fetchGeneralUserData: return .get
        case .modifyStudentUserData, .modifyGeneralUserData: return .put
        case .revoke: return .delete
        }
    }
    
    public var headers: [String: String] {
        var baseHeaders: [String: String] = [:]
        
        switch self {
        case .findPassword, .register, .checkDuplicatedPhoneNumber, .checkDuplicatedNickname, .login, .checkPassword, .modifyStudentUserData, .refreshToken, .sendVerificationCode, .checkVerificationCode, .checkDuplicatedId, .studentRegisterForm, .generalRegisterForm, .sendVerificationEmail, .checkVerificationEmail, .findIdEmail, .findIdSms, .modifyGeneralUserData, .resetPasswordSms, .resetPasswordEmail:
            baseHeaders["Content-Type"] = "application/json"
        case .fetchStudentUserData, .revoke, .checkAuth, .checkLogin, .fetchGeneralUserData:
            break
        }
            switch self {
            case .fetchStudentUserData, .revoke, .modifyStudentUserData, .checkPassword, .checkAuth , .fetchGeneralUserData, .modifyGeneralUserData:
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
        case .fetchStudentUserData:
            return nil
        case .fetchGeneralUserData:
            return nil
        case .checkPassword(let request):
            return try? JSONEncoder().encode(request)
        case .modifyStudentUserData(let request):
            return try? JSONEncoder().encode(request)
        case .modifyGeneralUserData(let request):
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
        case .sendVerificationEmail(let request):
            return try? JSONEncoder().encode(request)
        case .checkVerificationEmail(let request):
            return try? JSONEncoder().encode(request)
        case .findIdSms(let request):
            return try? JSONEncoder().encode(request)
        case .findIdEmail(let request):
            return try? JSONEncoder().encode(request)
        case .resetPasswordSms(let request):
            return try? JSONEncoder().encode(request)
        case .resetPasswordEmail(let request):
            return try? JSONEncoder().encode(request)
        }
    }
    
    public var encoding: Alamofire.ParameterEncoding? {
        switch self {
        case .findPassword, .register, .login, .checkPassword, .modifyStudentUserData, .sendVerificationCode, .checkVerificationCode, .studentRegisterForm, .generalRegisterForm, .checkVerificationEmail, .sendVerificationEmail, .findIdSms, .findIdEmail, .modifyGeneralUserData, .resetPasswordSms, .resetPasswordEmail: return JSONEncoding.default
        case .checkDuplicatedPhoneNumber, .checkDuplicatedNickname, .fetchStudentUserData, .checkAuth, .checkDuplicatedId, .fetchGeneralUserData: return URLEncoding.default
        case .checkLogin: return URLEncoding.queryString
        case .revoke, .refreshToken: return nil
        }
    }
}
