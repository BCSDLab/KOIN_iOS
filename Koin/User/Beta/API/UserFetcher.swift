//
//  UserFetcher.swift
//  Koin
//
//  Created by 정태훈 on 2020/05/11.
//  Copyright © 2020 정태훈. All rights reserved.
//

import Foundation
import CryptoKit
import CryptoTokenKit
import Combine

protocol UserFetchable {
    func LogIn(email: String, password: String) -> AnyPublisher<UserData, UserError>
    func LogOut(token:String) -> AnyPublisher<Bool, UserError>
    func FindPassword(email: String) -> AnyPublisher<AddUserResponseData, UserError>
    func CheckNickname(nickname: String) -> AnyPublisher<Bool, UserError>
    func DeleteUser(token: String) -> AnyPublisher<DeleteUserResponseData, UserError>
    func AddUser(email:String, password:String) -> AnyPublisher<AddUserResponseData, UserError>
    func PutUser(token: String, password:String?, name:String?, nickname:String?, gender:Int?, identity:Int?, isGraduated:Bool?, studentNumber:String?, phoneNumber:String?) -> AnyPublisher<User, UserError>
    func CheckToken(token:String) -> AnyPublisher<TokenCheckResponse, UserError>
}

class UserFetcher {
    let isStage: Bool = true
    private let session: URLSession
    init(session: URLSession = .shared) {
        self.session = session
    }
}

extension UserFetcher: UserFetchable {
    func LogIn(email: String, password: String) -> AnyPublisher<UserData, UserError> {
        return postRequest(with: makeLogInUserRequest(isStage: isStage, email: email, password: password))
    }
    
    func LogOut(token:String) -> AnyPublisher<Bool, UserError> {
        return postRequest(with: makeLogOutUserRequest(isStage: isStage, token: token))
    }
    
    func FindPassword(email: String) -> AnyPublisher<AddUserResponseData, UserError> {
        return postRequest(with: makeFindPasswordUserRequest(isStage: isStage, email: email))
    }
    
    func CheckNickname(nickname: String) -> AnyPublisher<Bool, UserError> {
        return getRequest(with: makeCheckNicknameComponents(isStage: isStage, nickname: nickname))
    }
    
    func DeleteUser(token: String) -> AnyPublisher<DeleteUserResponseData, UserError> {
        return postRequest(with: makeDeleteUserRequest(isStage: isStage, token: token))
    }
    
    func AddUser(email: String, password: String) -> AnyPublisher<AddUserResponseData, UserError> {
        return postRequest(with: makeAddUserRequest(isStage: isStage, email: email, password: password))
    }
    
    func PutUser(token: String, password: String? = nil, name: String? = nil, nickname: String? = nil, gender: Int? = nil, identity: Int? = nil, isGraduated: Bool? = nil, studentNumber: String? = nil, phoneNumber: String? = nil) -> AnyPublisher<User, UserError> {
        return postRequest(with: makeUpdateUserRequest(isStage: isStage, token: token, password: password, name: name, nickname: nickname, gender: gender, identify: identity, isGraduated: isGraduated, studentNumber: studentNumber, phoneNumber: phoneNumber))
    }
    
    func CheckToken(token: String) -> AnyPublisher<TokenCheckResponse, UserError> {
        return postRequest(with: makeTokenCheckRequest(isStage: isStage, token: token))
    }
    
    // MARK: 게시판 목록, 게시판 불러오는 기능
    private func getRequest<T>(with components: URLComponents) -> AnyPublisher<T, UserError> where T: Decodable {
        guard let url = components.url else {
            return Fail(error: UserError.network(description: "URL을 만들 수 없습니다.")).eraseToAnyPublisher()
        }
        
        return session.dataTaskPublisher(for: URLRequest(url: url))
            .mapError { error in
                return UserError.network(description: error.localizedDescription)
        }
        .tryMap { element -> Data in
            if let httpResponse = element.response as? HTTPURLResponse {
                if httpResponse.statusCode == 200 {
                    return element.data
                } else {
                    let error = try JSONDecoder().decode(ErrorResponse.self, from: element.data)
                    throw UserError.network(description: "\(error.error.message) #\(error.error.code) ( 에러코드: \(httpResponse.statusCode)")
                }
            } else {
                throw UserError.network(description: "오류가 발생하였습니다.")
            }
        }
        .mapError { error in
            return error as! UserError
        }
        .flatMap { data -> AnyPublisher<T, UserError> in
            return decode(data)
        }
        .eraseToAnyPublisher()
    }
    
    
    private func postRequest<T>(with user: UserRequest) -> AnyPublisher<T, UserError> where T: Decodable {
        if user.isError() {
            return Fail(error: user.getError() as! UserError).eraseToAnyPublisher()
        } else {
            return session.dataTaskPublisher(for: user.getRequest())
                .mapError { error in
                    return UserError.network(description: error.localizedDescription)
                }
            .tryMap { element -> Data in
                    if let httpResponse = element.response as? HTTPURLResponse {
                        if httpResponse.statusCode == 200 || httpResponse.statusCode == 201 {
                            print(element.response)
                            return element.data
                        } else {
                            let error = try JSONDecoder().decode(ErrorResponse.self, from: element.data)
                            throw UserError.network(description: "\(error.error.message) (에러코드 : \(error.error.code))")
                        }
                    } else {
                        throw UserError.network(description: "오류가 발생하였습니다.")
                    }
            }
            .mapError { error in
                print(error)
                return UserError.network(description: error.localizedDescription)
            }
            .flatMap { data -> AnyPublisher<T, UserError> in
                return decode(data)
            }
            .eraseToAnyPublisher()
            
        }
    }
    
}

extension UserFetcher {
    struct UserAPI {
        static let scheme = "https"
        static let stageScheme = "http"
        static let productionHost = "api.koreatech.in"
        static let stageHost = "stage.api.koreatech.in"
        static let path = "/user"
    }
    
    func hashed(pw: String) -> String{
        // 비밀번호를 먼전 Data로 변환하여
        let inputData = Data(pw.utf8)
        // SHA256을 이용해 해시 처리한 다음
        let hashed = SHA256.hash(data: inputData)
        // 해시 당 16진수 2자리로 설정하여 합친다.
        let hashPassword = hashed.compactMap {String(format: "%02x", $0)}.joined().trimmingCharacters(in: CharacterSet.newlines)
        return hashPassword
    }
    
    func school_number_to_major(school_number: String) -> String {
        // swift의 경우, string을 자를 때 int기반이 아닌 index를 이용해야하므로 해당 index를 생성해줘야한다.
        // 4번째 글자부터 자르기 위해 만든 index
        let indexStartOfText = school_number.index(school_number.startIndex, offsetBy: 4)
        // 뒤에서 3번째 글자까지 자르기 위해 만든 index
        let indexEndOfText = school_number.index(school_number.endIndex, offsetBy: -3)
        // 4번째 글자부터 뒤에서 3번째 글자까지 자른 값을 substring 변수에 저장한다.(전공에 해당되는 값)
        let substring = school_number[indexStartOfText..<indexEndOfText]
        
        // 이 값을 int로 변환해서 해당 값에 맞는 전공을 반환한다.
        switch Int(substring) {
            case 120:
                return "기계공학부"
            case 135, 136:
                return "컴퓨터공학부"
            case 140:
                return "메카트로닉스공학부"
            case 161:
                return "전기전자통신공학부"
            case 151:
                return "디자인건축공학부"
            case 174:
                return "에너지신소재화학공학부"
            case 180:
                return "산업경영학부"
            default:
                return ""
        }
    }
    
    func makeLogInComponents(isStage: Bool) -> URLComponents {
        var components = URLComponents()
        components.scheme = isStage ? UserAPI.stageScheme : UserAPI.scheme
        components.host = isStage ? UserAPI.stageHost : UserAPI.productionHost
        components.path = UserAPI.path + "/login"
        
        return components
    }
    
    func makeLogInUserRequest(isStage: Bool, email: String, password: String) -> UserRequest {
        let components = makeLogInComponents(isStage: isStage)
        
        var request = URLRequest(url: components.url!)
        print(components.url!)
        request.httpMethod = "POST"
        request.setValue("application/json; charset=utf-8", forHTTPHeaderField: "Content-Type")
        let parameters: [String: Any] = ["portal_account": email, "password": hashed(pw: password)]
        print(parameters)
        do {
            request.httpBody = try JSONSerialization.data(withJSONObject: parameters, options: .prettyPrinted)
        } catch let error {
            return UserRequest(request: nil, error: UserError.network(description: error.localizedDescription))
        }
        print(request.httpBody)
        return UserRequest(request: request, error: nil)
    }
    
    func makeLogOutComponents(isStage: Bool) -> URLComponents {
        var components = URLComponents()
        components.scheme = isStage ? UserAPI.stageScheme : UserAPI.scheme
        components.host = isStage ? UserAPI.stageHost : UserAPI.productionHost
        components.path = UserAPI.path + "/logout"
        
        return components
    }
    
    func makeLogOutUserRequest(isStage: Bool, token: String) -> UserRequest {
        let components = makeLogInComponents(isStage: isStage)
        
        var request = URLRequest(url: components.url!)
        request.httpMethod = "POST"
        request.setValue("application/json; charset=utf-8", forHTTPHeaderField: "Content-Type")
        request.addValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        
        return UserRequest(request: request, error: nil)
    }
    
    func makeFindPasswordComponents(isStage: Bool) -> URLComponents {
        var components = URLComponents()
        components.scheme = isStage ? UserAPI.stageScheme : UserAPI.scheme
        components.host = isStage ? UserAPI.stageHost : UserAPI.productionHost
        components.path = UserAPI.path + "/find/password"
        
        return components
    }
    
    func makeFindPasswordUserRequest(isStage: Bool, email: String) -> UserRequest {
        let components = makeFindPasswordComponents(isStage: isStage)
        
        var request = URLRequest(url: components.url!)
        request.httpMethod = "POST"
        request.setValue("application/json; charset=utf-8", forHTTPHeaderField: "Content-Type")
        let parameters: [String: Any] = ["portal_account": email]
        do {
            request.httpBody = try JSONSerialization.data(withJSONObject: parameters, options: .prettyPrinted)
        } catch let error {
            return UserRequest(request: nil, error: UserError.network(description: error.localizedDescription) )
        }
        return UserRequest(request: request, error: nil)
    }
    
    func makeCheckNicknameComponents(isStage: Bool, nickname: String) -> URLComponents {
        var components = URLComponents()
        components.scheme = isStage ? UserAPI.stageScheme : UserAPI.scheme
        components.host = isStage ? UserAPI.stageHost : UserAPI.productionHost
        components.path = UserAPI.path + "/check/nickname/\(nickname)"
        
        return components
    }
    
    func makeDeleteUserComponents(isStage: Bool) -> URLComponents {
        var components = URLComponents()
        components.scheme = isStage ? UserAPI.stageScheme : UserAPI.scheme
        components.host = isStage ? UserAPI.stageHost : UserAPI.productionHost
        components.path = UserAPI.path + "/me"
        
        return components
    }
    
    func makeDeleteUserRequest(isStage: Bool, token: String) -> UserRequest {
        let components = makeDeleteUserComponents(isStage: isStage)
        
        var request = URLRequest(url: components.url!)
        request.httpMethod = "DELETE"
        request.setValue("application/json; charset=utf-8", forHTTPHeaderField: "Content-Type")
        request.addValue("Bearer \(token)", forHTTPHeaderField: "Authorization")

        return UserRequest(request: request, error: nil)
    }
    
    func makeAddUserComponents(isStage: Bool) -> URLComponents {
        var components = URLComponents()
        components.scheme = isStage ? UserAPI.stageScheme : UserAPI.scheme
        components.host = isStage ? UserAPI.stageHost : UserAPI.productionHost
        components.path = UserAPI.path + "/register"
        
        return components
    }
    
    func makeAddUserRequest(isStage: Bool, email: String, password: String) -> UserRequest {
        let components = makeAddUserComponents(isStage: isStage)
        
        var request = URLRequest(url: components.url!)
        request.httpMethod = "POST"
        request.setValue("application/json; charset=utf-8", forHTTPHeaderField: "Content-Type")
        let parameters: [String: Any] = ["portal_account": email, "password": hashed(pw: password)]
        print(hashed(pw: password))
        do {
            request.httpBody = try JSONSerialization.data(withJSONObject: parameters, options: .prettyPrinted)
        } catch let error {
            return UserRequest(request: nil, error: UserError.network(description: error.localizedDescription))
        }
        return UserRequest(request: request, error: nil)
    }
    
    func makeUpdateUserRequest(isStage: Bool,token:String, password: String?, name: String?, nickname: String?, gender: Int?, identify: Int?, isGraduated: Bool?, studentNumber: String?, phoneNumber: String?) -> UserRequest {
        let components = makeDeleteUserComponents(isStage: isStage)
        
        var request = URLRequest(url: components.url!)
        request.httpMethod = "PUT"
        request.setValue("application/json; charset=utf-8", forHTTPHeaderField: "Content-Type")
        request.addValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        var parameters: [String: Any] = [:]
        
        if let password = password {
            parameters["password"] = password
        }
        if let name = name {
            parameters["name"] = name
        }
        if let nickname = nickname {
            parameters["nickname"] = nickname
        }
        if let gender = gender {
            parameters["gender"] = gender
        }
        if let identify = identify {
            parameters["identify"] = identify
        }
        if let isGraduated = isGraduated {
            parameters["is_graduated"] = isGraduated
        }
        if let studentNumber = studentNumber {
            parameters["major"] = school_number_to_major(school_number: studentNumber)
            parameters["student_number"] = studentNumber
        }
        if let phoneNumber = phoneNumber {
            parameters["phone_number"] = phoneNumber
        }
        
        do {
            request.httpBody = try JSONSerialization.data(withJSONObject: parameters, options: .prettyPrinted)
        } catch let error {
            return UserRequest(request: nil, error: UserError.network(description: error.localizedDescription))
        }
        return UserRequest(request: request, error: nil)
    }
    
    func makeTokenCheckRequest(isStage: Bool,token:String) -> UserRequest {
        let components = makeDeleteUserComponents(isStage: isStage)
        
        var request = URLRequest(url: components.url!)
        request.httpMethod = "GET"
        request.setValue("application/json; charset=utf-8", forHTTPHeaderField: "Content-Type")
        request.addValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        
        return UserRequest(request: request, error: nil)
    }
}



