//
//  UserSettings.swift
//  dev_koin
//
//  Created by 정태훈 on 2019/12/24.
//  Copyright © 2019 정태훈. All rights reserved.
//

import SwiftUI
import Alamofire
import CryptoKit
import CryptoTokenKit
import Foundation
import Combine

// There is no such ID : 인증 안된 상태 또는 회원가입이 안된 상태
// invalid authenticate : 이미 가입되어있는 상태

class UserSettings: ObservableObject {
    var isTest = true
    var api = ""
    // 유저 정보
    @Published var user: UserRequest? = nil
    // 업데이트할 유저 정보
    @Published var userInfo: [String: String] = [:]
    // 로그인이 되어있는지 여부
    @Published var isLogin: Bool = false
    // 값이 바뀌었는지 여부
    @Published var isChanged: Bool = false
    
    let didChange = PassthroughSubject<UserSettings,Never>()

    struct UserError: LocalizedError, Equatable {

       private var description: String!

       init(description: String) {
           self.description = description
       }

       var errorDescription: String? {
           return description
       }

       public static func ==(lhs: UserError, rhs: UserError) -> Bool {
           return lhs.description == rhs.description
       }
    }
    
    
    
    @Published var nameValue = "" {
        didSet {
            if nameValue.count > 5 && oldValue.count <= 5 {
                nameValue = oldValue
            }
        }
    }
    
    @Published var nicknameValue = "" {
        didSet {
            if nicknameValue.count > 10 && oldValue.count <= 10 {
                nicknameValue = oldValue
            }
        }
    }
    
    @Published var phoneValue = "" {
        didSet {
            if phoneValue.count > 11 && oldValue.count <= 11 {
                phoneValue = oldValue
            }
        }
    }
    
    @Published var studentNumberValue = "" {
        didSet {
            if studentNumberValue.count > 10 && oldValue.count <= 10 {
                studentNumberValue = oldValue
            }
        }
    }
    
    init() {
        api = isTest ? "http://stage.api.koreatech.in" : "https://api.koreatech.in"
        // 로그인이 되었는지 확인
        self.login_succeed()
    }
    
    // 유저정보 제거
    func remove_user() {
        self.user = nil
    }
    
    // 패스워드가 일치하는지 확인
    func check_valid_password(password: String, valid_password: String) -> Bool {
        // 두 값을 모두 해시처리하고
        let hashPassword = hashed(pw: password)
        let hashValidPassword = hashed(pw: valid_password)
        
        // 값이 일치하면 true, 아니면 false
        if hashPassword == hashValidPassword {
            return true
        } else {
            return false
        }
    }
    
    func get_userId() -> Int {
        if let user = self.user {
            if let userdata = user.user {
                return userdata.id
            }
        }
        return -1
    }
    func get_nickname() -> String {
        if let user = self.user {
            if let userdata = user.user {
                if let nickname = userdata.nickname {
                    return nickname
                }
            }
        }
        return ""
    }
    
    // 토큰을 주는 함수
    func get_token() -> String {
        // 유저가 nil이 아니면
        if let user = self.user {
            // 유저 내의 token값이 nil이 아니면
            if let token = user.token {
                // 해당 값을 준다.
                return token
            }
        }
        return ""
    }
    
    func convertToDictionary(data: Data?) -> [String: Any]? {
            do {
                return try JSONSerialization.jsonObject(with: data!, options: []) as? [String: Any]
            } catch {
                print(error.localizedDescription)
            }
        return nil
    }
    
    func convertToDictionary(text: String) -> [String: Any]? {
        if let data = text.data(using: .utf8) {
            do {
                return try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any]
            } catch {
                print(error.localizedDescription)
            }
        }
        return nil
    }
    
    func check_expired() -> Bool {
        let d = get_token().split(separator: ".")
        if d.isEmpty {
            return false
        }
        if let decodedData = Data(base64Encoded: String(d[1])) {
            if let decodedString = String(data: decodedData, encoding: .utf8) {
                let decodedDict = convertToDictionary(text: decodedString)
                if let expTime = decodedDict!["exp"] {
                    let tm = Date(timeIntervalSince1970: expTime as! TimeInterval)
                    if Date() > tm {
                        return true
                    } else {
                        return false
                    }
                }
                return false
            }
            return false
            
        }
        return false
    }
    
    func expired_token() -> Bool {
        if(check_expired()) {
            logout_session()
            return true
        } else {
            return false
        }
    }
    
    func get_userId_by_token() -> Int {
        let d = get_token().split(separator: ".")
        let decodedData = Data(base64Encoded: String(d[1]))!
        let decodedString = String(data: decodedData, encoding: .utf8)!
        let decodedDict = convertToDictionary(text: decodedString)
        let userId = Int(decodedDict!["sub"]! as! String)!
        return userId
    }
    
    // 비밀번호를 해시로 변환해주는 함수
    func hashed(pw: String) -> String{
        // 비밀번호를 먼전 Data로 변환하여
        let inputData = Data(pw.utf8)
        // SHA256을 이용해 해시 처리한 다음
        let hashed = SHA256.hash(data: inputData)
        // 해시 당 16진수 2자리로 설정하여 합친다.
        let hashPassword = hashed.compactMap {String(format: "%02x", $0)}.joined().trimmingCharacters(in: CharacterSet.newlines)
        return hashPassword
    }
    
    // 주는 값 없이 유저 정보를 업데이트하는 함수(대부분 유저 정보를 받는 쪽으로 활용)
    func update_data(token: String, result: @escaping (User?, Error?) -> Void) {
        // Bearer Auth를 이용하기 위한 Header 추가
        let headers: HTTPHeaders = [
            "Authorization": "Bearer " + token
        ]
        
        // put 메서드로, header추가하여 request를 보내주면
        AF
        .request("\(api)/user/me", method: .put, encoding: JSONEncoding.prettyPrinted, headers: headers)
        .response { response in // 응답이 오면
            // 해당 응답에서 data를 꺼내
             let decoder = JSONDecoder()
                                   switch response.result {
                                       case .success(let data):
                                           do{
                                              let user = try decoder.decode(User.self, from: data!)
                                               // 받은 user(User)는 해당 user(UserRequest) 내부의 user(User)에 넣어준다.
                                               self.user?.user = user

                                               // 인코더를 설정하여
                                               let encoder = JSONEncoder()
                                               // 현재 user(UserRequest)를 인코딩할 수 있으면
                                               if let encoded = try? encoder.encode(self.user) {
                                                   // UserDefaults에 "user"란 이름으로 인코딩된 user를 저장하고
                                                   UserDefaults.standard.set(encoded, forKey: "user")
                                                   result(user, nil)
                                               }
                                           } catch(let error) {
                                               result(nil, error)
                                       }
                                       case .failure(let error):
                                           result(nil, error)
                                   }
            
        }
    }
    
    // portal_account : ^[a-z_0-9]{1,12}$
    
    /*
     public final static String FILTER_E_N_H = "^[ㄱ-ㅎㅏ-ㅣ가-힣a-zA-Z0-9\u318D\u119E\u11A2\u2022\u2025a\u00B7\uFE55]+$";
     public final static String FILTER_E_H = "^[ㄱ-ㅎㅏ-ㅣ가-힣a-zA-Z\u318D\u119E\u11A2\u2022\u2025a\u00B7\uFE55]+$";
     public final static String FILTERPASSWORD = "^(?=.[a-zA-Z])(?=.[`₩~!@#$%<>^&*()\-=+?<>:;"',.{}|[]/\\]])(?=.*[0-9]).{6,18}$";
     public final static String FILTER_EMAIL = "^[a-z_0-9]{1,12}$";
     */
    
    // 학번을 넣어주면 전공을 반환해주는 함수
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
    
    func update_name(token: String, updated_name: String = "", result: @escaping (Bool, Error?) -> Void) {
        
        let range = NSRange(location: 0, length: updated_name.utf16.count)
        let regex = try! NSRegularExpression(pattern: "^[ㄱ-ㅎㅏ-ㅣ가-힣a-zA-Z\\u318D\\u119E\\u11A2\\u2022\\u2025a\\u00B7\\uFE55]{1,10}$")
        let filtered = regex.matches(in: updated_name, options: [], range: range)
        
        if (filtered.isEmpty) {
            result(false, UserError(description: NSLocalizedString("이름 형태가 올바르지 않습니다.",comment: "")))
        } else {
            // 빈 파라미터를 생성
            var parameters: [String: Any] = [:]
            // 닉네임이 비어있지 않고 전과 똑같은 닉네임이 아니라면, 닉네임을 파라미터에 추가
            if !updated_name.isEmpty {parameters["name"] = updated_name}
            
            
            // Bearer Auth를 이용하기 위한 Header 추가
            let headers: HTTPHeaders = [
                            "Authorization": "Bearer " + token
                        ]
                        
            // put 메서드로, header추가하고, 변경된 값을 parameter에 넣어 request를 보내주면
                        AF
                        .request("\(api)/user/me", method: .put, parameters:  parameters, encoding: JSONEncoding.prettyPrinted, headers: headers)
                        .response { response in // 응답이 오면
                             let decoder = JSONDecoder()
                                                   switch response.result {
                                                       case .success(let data):
                                                           do{
                                                              let user = try decoder.decode(User.self, from: data!)
                                                               // 받은 user(User)는 해당 user(UserRequest) 내부의 user(User)에 넣어준다.
                                                               self.user?.user = user

                                                               // 인코더를 설정하여
                                                               let encoder = JSONEncoder()
                                                               // 현재 user(UserRequest)를 인코딩할 수 있으면
                                                               if let encoded = try? encoder.encode(self.user) {
                                                                   // UserDefaults에 "user"란 이름으로 인코딩된 user를 저장하고
                                                                   UserDefaults.standard.set(encoded, forKey: "user")
                                                                   // 데이터가 변경되었다고 알려준다.
                                                                   self.isChanged = true
                                                                   result(true, nil)
                                                               }
                                                           } catch(let error) {
                                                               result(false, error)
                                                       }
                                                       case .failure(let error):
                                                           result(false, error)
                                                   }
                        }
        }
        
        
    }
    
    func update_nickname(token: String, updated_nickname: String = "", result: @escaping (Bool, Error?) -> Void) {
        
        let range = NSRange(location: 0, length: updated_nickname.utf16.count)
        let regex = try! NSRegularExpression(pattern: "^[ㄱ-ㅎㅏ-ㅣ가-힣a-zA-Z0-9\\u318D\\u119E\\u11A2\\u2022\\u2025a\\u00B7\\uFE55]{1,10}$")
        let filtered = regex.matches(in: updated_nickname, options: [], range: range)
        
        if (filtered.isEmpty) {
            result(false, UserError(description: NSLocalizedString("닉네임 형태가 올바르지 않습니다.",comment: "")))
        } else {
            // 빈 파라미터를 생성
            var parameters: [String: Any] = [:]
            // 닉네임이 비어있지 않고 전과 똑같은 닉네임이 아니라면, 닉네임을 파라미터에 추가
            if !updated_nickname.isEmpty {parameters["nickname"] = updated_nickname}
            
            
            // Bearer Auth를 이용하기 위한 Header 추가
            let headers: HTTPHeaders = [
                            "Authorization": "Bearer " + token
                        ]
                        
            // put 메서드로, header추가하고, 변경된 값을 parameter에 넣어 request를 보내주면
                        AF
                        .request("\(api)/user/me", method: .put, parameters:  parameters, encoding: JSONEncoding.prettyPrinted, headers: headers)
                        .response { response in // 응답이 오면
                             let decoder = JSONDecoder()
                                                   switch response.result {
                                                       case .success(let data):
                                                           do{
                                                              let user = try decoder.decode(User.self, from: data!)
                                                               // 받은 user(User)는 해당 user(UserRequest) 내부의 user(User)에 넣어준다.
                                                               self.user?.user = user

                                                               // 인코더를 설정하여
                                                               let encoder = JSONEncoder()
                                                               // 현재 user(UserRequest)를 인코딩할 수 있으면
                                                               if let encoded = try? encoder.encode(self.user) {
                                                                   // UserDefaults에 "user"란 이름으로 인코딩된 user를 저장하고
                                                                   UserDefaults.standard.set(encoded, forKey: "user")
                                                                   // 데이터가 변경되었다고 알려준다.
                                                                   self.isChanged = true
                                                                   result(true, nil)
                                                               }
                                                           } catch(let error) {
                                                               result(false, error)
                                                       }
                                                       case .failure(let error):
                                                           result(false, error)
                                                   }
                        }
        }
        
        
    }
    
    func update_phoneNumber(token: String, updated_phoneNumber: String = "", result: @escaping (Bool, Error?) -> Void) {
        
        let range = NSRange(location: 0, length: updated_phoneNumber.utf16.count)
        let regex = try! NSRegularExpression(pattern: "^\\d{3}-\\d{3,4}-\\d{4}$")
        let filtered = regex.matches(in: updated_phoneNumber, options: [], range: range)
        
        if (filtered.isEmpty) {
            result(false, UserError(description: NSLocalizedString("휴대폰 번호 형태가 올바르지 않습니다.",comment: "")))
        } else {
            // 빈 파라미터를 생성
            var parameters: [String: Any] = [:]
            // 폰 번호가 비어있지않고 폰 번호가 바뀌었다면, 폰 번호를 파라미터에 추가
            if !updated_phoneNumber.isEmpty {parameters["phone_number"] = updated_phoneNumber}
            
            // Bearer Auth를 이용하기 위한 Header 추가
            let headers: HTTPHeaders = [
                            "Authorization": "Bearer " + token
                        ]
                        
            // put 메서드로, header추가하고, 변경된 값을 parameter에 넣어 request를 보내주면
                        AF
                        .request("\(api)/user/me", method: .put, parameters:  parameters, encoding: JSONEncoding.prettyPrinted, headers: headers)
                        .response { response in // 응답이 오면
                             let decoder = JSONDecoder()
                                                   switch response.result {
                                                       case .success(let data):
                                                           do{
                                                              let user = try decoder.decode(User.self, from: data!)
                                                               // 받은 user(User)는 해당 user(UserRequest) 내부의 user(User)에 넣어준다.
                                                               self.user?.user = user

                                                               // 인코더를 설정하여
                                                               let encoder = JSONEncoder()
                                                               // 현재 user(UserRequest)를 인코딩할 수 있으면
                                                               if let encoded = try? encoder.encode(self.user) {
                                                                   // UserDefaults에 "user"란 이름으로 인코딩된 user를 저장하고
                                                                   UserDefaults.standard.set(encoded, forKey: "user")
                                                                   // 데이터가 변경되었다고 알려준다.
                                                                   self.isChanged = true
                                                                   result(true, nil)
                                                               }
                                                           } catch(let error) {
                                                               result(false, error)
                                                       }
                                                       case .failure(let error):
                                                           result(false, error)
                                                   }
                        }
        }
        
        
    }
    
    func update_gender(token: String, updated_gender: Int = -1, result: @escaping (Bool, Error?) -> Void) {
        
        // 빈 파라미터를 생성
        var parameters: [String: Any] = [:]
        // 폰 번호가 비어있지않고 폰 번호가 바뀌었다면, 폰 번호를 파라미터에 추가
        if updated_gender != -1 {parameters["gender"] = updated_gender}
        
        // Bearer Auth를 이용하기 위한 Header 추가
        let headers: HTTPHeaders = [
                        "Authorization": "Bearer " + token
                    ]
                    
        // put 메서드로, header추가하고, 변경된 값을 parameter에 넣어 request를 보내주면
                    AF
                    .request("\(api)/user/me", method: .put, parameters:  parameters, encoding: JSONEncoding.prettyPrinted, headers: headers)
                    .response { response in // 응답이 오면
                         let decoder = JSONDecoder()
                                               switch response.result {
                                                   case .success(let data):
                                                       do{
                                                          let user = try decoder.decode(User.self, from: data!)
                                                           // 받은 user(User)는 해당 user(UserRequest) 내부의 user(User)에 넣어준다.
                                                           self.user?.user = user

                                                           // 인코더를 설정하여
                                                           let encoder = JSONEncoder()
                                                           // 현재 user(UserRequest)를 인코딩할 수 있으면
                                                           if let encoded = try? encoder.encode(self.user) {
                                                               // UserDefaults에 "user"란 이름으로 인코딩된 user를 저장하고
                                                               UserDefaults.standard.set(encoded, forKey: "user")
                                                               // 데이터가 변경되었다고 알려준다.
                                                               self.isChanged = true
                                                               result(true, nil)
                                                           }
                                                       } catch(let error) {
                                                           result(false, error)
                                                   }
                                                   case .failure(let error):
                                                       result(false, error)
                                               }
                    }
    }
    
    /*
     parameters["student_number"] = updated_studentNumber
     // school_number_to_major를 이용하여 학번에 전공을 추출하여 해당 값을 파라미터에 추가
     parameters["major"] = self.school_number_to_major(school_number: updated_studentNumber)
     */
    
    func update_studentNumber(token: String, updated_studentNumber: String = "", result: @escaping (Bool, Error?) -> Void) {
        
        let range = NSRange(location: 0, length: updated_studentNumber.utf16.count)
        let regex = try! NSRegularExpression(pattern: "^\\d{10}$")
        let filtered = regex.matches(in: updated_studentNumber, options: [], range: range)
        
        
        
        if (filtered.isEmpty) {
            result(false, UserError(description: NSLocalizedString("학번 형태가 올바르지 않습니다.",comment: "")))
        } else {
            var parameters: [String: Any] = [:]
            // 폰 번호가 비어있지않고 폰 번호가 바뀌었다면, 폰 번호를 파라미터에 추가
            parameters["student_number"] = updated_studentNumber
            // school_number_to_major를 이용하여 학번에 전공을 추출하여 해당 값을 파라미터에 추가
            parameters["major"] = self.school_number_to_major(school_number: updated_studentNumber)
            
            // Bearer Auth를 이용하기 위한 Header 추가
            let headers: HTTPHeaders = [
                            "Authorization": "Bearer " + token
                        ]
            
            AF
            .request("\(api)/user/me", method: .put, parameters:  parameters, encoding: JSONEncoding.prettyPrinted, headers: headers)
            .response { response in // 응답이 오면
                // 해당 응답에서 data를 꺼내
                let decoder = JSONDecoder()
                switch response.result {
                    case .success(let data):
                        do{
                           let user = try decoder.decode(User.self, from: data!)
                            // 받은 user(User)는 해당 user(UserRequest) 내부의 user(User)에 넣어준다.
                            self.user?.user = user

                            // 인코더를 설정하여
                            let encoder = JSONEncoder()
                            // 현재 user(UserRequest)를 인코딩할 수 있으면
                            if let encoded = try? encoder.encode(self.user) {
                                // UserDefaults에 "user"란 이름으로 인코딩된 user를 저장하고
                                UserDefaults.standard.set(encoded, forKey: "user")
                                // 데이터가 변경되었다고 알려준다.
                                self.isChanged = true
                                result(true, nil)
                            }
                        } catch(let error) {
                            result(false, error)
                    }
                    case .failure(let error):
                        result(false, error)
                }
            }
        }
        
        
                    
        // put 메서드로, header추가하고, 변경된 값을 parameter에 넣어 request를 보내주면
                    
    }
    /*
    // 유저 정보를 업데이트하는 함수
    func update_session(token: String, updated_password: String = "", updated_name: String = "", updated_nickname: String = "", updated_gender: Int = -1, updated_isGraduated: Bool = false, updated_studentNumber: String = "", updated_phoneNumber: String = "", changed_name: Bool = false, changed_gender: Bool = false, changed_phoneNumber: Bool = false, changed_studentNumber: Bool = false, changed_nickname: Bool = false, result: @escaping (Bool) -> Void) {
        
        // 빈 파라미터를 생성
        var parameters: [String: Any] = [:]
        // 패스워드가 비워있지 않으면, 해시 형태의 페스워드를 파라미터에 추가
        if !updated_password.isEmpty {parameters["password"] = hashed(pw: updated_password)}
        // 이름이 비어있지 않고 전과 똑같은 이름이 아니라면, 이름을 파라미터에 추가
        if !updated_name.isEmpty && changed_name {parameters["name"] = updated_name}
        // 닉네임이 비어있지 않고 전과 똑같은 닉네임이 아니라면, 닉네임을 파라미터에 추가
        if !updated_nickname.isEmpty && changed_nickname {parameters["nickname"] = updated_nickname}
        // 성별이 비어있지 않고(-1) 성별이 바뀌었다면, 성별을 파라미터에 추가
        if updated_gender != -1 && changed_gender {parameters["gender"] = updated_gender}
        // 졸업 여부가 있다면, 졸업 여부를 파라미터에 추가(현재 이용하지 않음)
        if updated_isGraduated {parameters["is_graduated"] = updated_isGraduated}
        // 학번이 비어있지 않고 학번이 바뀌었으면
        if !updated_studentNumber.isEmpty && changed_studentNumber {
            // 학번을 파라미터에 추가하고
            parameters["student_number"] = updated_studentNumber
            // school_number_to_major를 이용하여 학번에 전공을 추출하여 해당 값을 파라미터에 추가
            parameters["major"] = self.school_number_to_major(school_number: updated_studentNumber)
        }
        // 폰 번호가 비어있지않고 폰 번호가 바뀌었다면, 폰 번호를 파라미터에 추가
        if !updated_phoneNumber.isEmpty && changed_phoneNumber {parameters["phone_number"] = updated_phoneNumber}
        
        // 이제 변경된 정보는 모두 파라미터에 저장된 상태
        
        // Bearer Auth를 이용하기 위한 Header 추가
        let headers: HTTPHeaders = [
                        "Authorization": "Bearer " + token
                    ]
                    
        // put 메서드로, header추가하고, 변경된 값을 parameter에 넣어 request를 보내주면
                    AF
                    .request("\(api)/user/me", method: .put, parameters:  parameters, encoding: JSONEncoding.prettyPrinted, headers: headers)
                    .response { response in // 응답이 오면
                        // 해당 응답에서 data를 꺼내
                        guard let data = response.data else { return }
                        do {
                            // 디코더를 설정하고
                            let decoder = JSONDecoder()
                            // 데이터를 User에 맞게 가공한다.
                            let user = try decoder.decode(User.self, from: data)
                            
                            // 받은 user(User)는 해당 user(UserRequest) 내부의 user(User)에 넣어준다.
                            self.user?.user = user

                            // 인코더를 설정하여
                            let encoder = JSONEncoder()
                            // 현재 user(UserRequest)를 인코딩할 수 있으면
                            if let encoded = try? encoder.encode(self.user) {
                                // UserDefaults에 "user"란 이름으로 인코딩된 user를 저장하고
                                UserDefaults.standard.set(encoded, forKey: "user")
                                // 데이터가 변경되었다고 알려준다.
                                self.isChanged = true
                                result(true)
                            }
                            
                            
                        } catch let error {
                            result(false)
                        }
                    }
    }
    */
    // 회원가입 기능을 담당하는 함수
    func register_session(email: String, password: String, result: @escaping (Bool, Error?) -> Void) {
        
        let passwordRange = NSRange(location: 0, length: password.utf16.count)
        let passwordRegex = try! NSRegularExpression(pattern: "^.*(?=^.{6,18}$)(?=.*\\d)(?=.*[a-zA-Z])(?=.*[!@#$%^&+=]).*$")
        let passwordFiltered = passwordRegex.matches(in: password, options: [], range: passwordRange)
        
        let emailRange = NSRange(location: 0, length: email.utf16.count)
        let emailRegex = try! NSRegularExpression(pattern: "^[a-z_0-9]{1,12}$")
        let emailFiltered = emailRegex.matches(in: email, options: [], range: emailRange)
        
        if (emailFiltered.isEmpty) {
            result(false, UserError(description: NSLocalizedString("이메일 형식이 올바르지 않습니다.",comment: "")))
        } else if (passwordFiltered.isEmpty) {
            result(false, UserError(description: NSLocalizedString("비밀번호 형식이 올바르지 않습니다.",comment: "")))
        } else {
            let hashPassword = hashed(pw: password)
            // post 메소드로, 이메일, 해시 비밀번호를 파라미터에 넣어 보내면
                AF
                .request("\(api)/user/register", method: .post, parameters:  ["portal_account": email, "password": hashPassword], encoding: JSONEncoding.prettyPrinted)
                .response { response in // JSON 형태로 응답을 받아
                    
                    switch response.result {
                    case .success(let data):
                        let data = self.convertToDictionary(data: data)
                        if let status = response.response?.statusCode { // 상태 코드를 가져와서
                            switch(status){
                            case 200:
                                fallthrough
                            case 201: // 겹치지 않으면(200)
                                print(data)
                                result(true, nil) // 겹치지 않는다고 알림
                                break
                            default: // 겹치거나 오류가 나면
                                let error = data!["error"] as! [String:Any]
                                let message = error["message"] as! String
                                result(false, UserError(description: NSLocalizedString(message,comment: ""))) // 겹친다고 알림
                                break
                            }
                        }
                    case .failure(let error):
                        result(false, error)
                    }
                    
                }
        }
        // 비밀번호를 hash 처리하고
        
    }
    
    // 로그인이 성공했는지 여부를 확인하는 함수
    func login_succeed(){
        // UserDefaults에서 인코딩된 유저 정보를 가져와서
        if let data = UserDefaults.standard.object(forKey:"user") as? Data {
            // 디코더를 가져와서
            let decoder = JSONDecoder()
            // 해당 값을 UserReqeust 형태로 가공해서
            if let loaded = try? decoder.decode(UserRequest.self, from: data) {
                // 토큰이 비어있지 않으면
                if loaded.token != nil {
                    // user(UserRequest)에 가공된 값을 저장하고
                    self.user = loaded
                    // 로그인이 되었다고 알림
                    self.isLogin = true
                }
                
            }
        }
    }
    
    // 회원 탈퇴 기능
    func delete_session(token: String, result: @escaping (Bool, Error?) -> Void) {
        // Bearer Auth를 이용하기 위한 헤더
        let headers: HTTPHeaders = [
            "Authorization": "Bearer "+token
        ]
        
        //delete 메서드로 헤더와 같이 넣어서 보내주면
        AF
        .request("\(api)/user/me", method: .delete, encoding: URLEncoding.httpBody,headers: headers)
        .response { response in // 응답을 받으면
            switch response.result {
            case .success(let data):
                let data = self.convertToDictionary(data: data)
                print(data)
                if let status = response.response?.statusCode { // 상태 코드를 가져와서
                    switch(status){
                    case 200:
                        fallthrough
                    case 201: // 겹치지 않으면(200)
                        // UserDefaults의 user값을 삭제하고
                        UserDefaults.standard.set(nil, forKey: "user")
                        // 내부 class의 user값을 지우고
                        self.user = nil
                        // 로그아웃시키기
                        self.isLogin = false
                        result(true, nil) // 겹치지 않는다고 알림
                        break
                    default: // 겹치거나 오류가 나면
                        let error = data!["error"] as! [String:Any]
                        let message = error["message"] as! String
                        result(false, UserError(description: NSLocalizedString(message,comment: ""))) // 겹친다고 알림
                        break
                    }
                }
            case .failure(let error):
                result(false, error)
            }
        }
    }

    // 닉네임이 존재하는지 확인하는 함수
    func check_nickname(nickname: String, result: @escaping (Bool, Error?) -> Void) {
        // 한글을 그대로 넣을 수 없어 임의로 주소 string으로 url로 인코딩해서 변환
        let url = "\(api)/user/check/nickname/\(nickname)"
        if let url_encode = url.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) {
            // 해당 주소를 get 메서드로 보내면
            AF
                    .request(url_encode, method: .get, encoding: JSONEncoding.default)
                    .response { response in // JSON 형태로 응답받으면
                        switch response.result {
                        case .success(let data):
                            let data = self.convertToDictionary(data: data)
                            if let status = response.response?.statusCode { // 상태 코드를 가져와서
                                switch(status){
                                case 200:
                                    fallthrough
                                case 201: // 겹치지 않으면(200)
                                    result(true, nil) // 겹치지 않는다고 알림
                                    break
                                default: // 겹치거나 오류가 나면
                                    let error = data!["error"] as! [String:Any]
                                    let message = error["message"] as! String
                                    result(false, UserError(description: NSLocalizedString(message,comment: ""))) // 겹친다고 알림
                                    break
                                }
                            }
                        case .failure(let error):
                            result(false, error)
                        }
                    }
        } else {
            result(false, UserError(description: NSLocalizedString("닉네임 방식에 문제가 있습니다. 다른 닉네임으로 입력하세요.",comment: "")))
        }
    }
    
    
    func find_password(email: String, result: @escaping (Bool, Error?) -> Void) {
        AF
        .request("\(api)/user/find/password", method: .post, parameters:  ["portal_account": email], encoding: JSONEncoding.prettyPrinted)
        .response { response in // JSON 형태로 응답받으면
            switch response.result {
            case .success(let data):
                let data = self.convertToDictionary(data: data)
                print(data)
                if let status = response.response?.statusCode { // 상태 코드를 가져와서
                    print(status)
                    switch(status){
                    case 200:
                        fallthrough
                    case 201: // 겹치지 않으면(200)
                        result(true, nil) // 겹치지 않는다고 알림
                        break
                    default: // 겹치거나 오류가 나면
                        let error = data!["error"] as! [String:Any]
                        let message = error["message"] as! String
                        result(false, UserError(description: NSLocalizedString(message,comment: ""))) // 겹친다고 알림
                        break
                    }
                }
            case .failure(let error):
                result(false, error)
            }

        }
        
    }
    
    // 로그아웃 기능을 담당하는 함수
    func logout_session() {
        // UserDefaults의 user 값을 지우고
        UserDefaults.standard.set(nil, forKey: "user")
        // 해당 Class의 유저값을 지우고
        self.user = nil
        // 로그아웃을 한다.
        self.isLogin = false
    }
    
    // 로그인 기능을 담당하는 함수
    func login_session(email: String, password: String, result: @escaping (Bool, Error?) -> Void) {
        // 비밀번호를 해시 처리하여
        let hashPassword = hashed(pw: password)
        // post 메서드로, 아이디와 비밀번호를 파라미터에 같이 넣어 보내주면
        print(email, hashPassword)
            AF
                .request("\(api)/user/login", method: .post, parameters:  ["portal_account": email,"password": hashPassword], encoding: JSONEncoding.default)
            .response { response in // 응답을 받으면
                let decoder = JSONDecoder()
                switch response.result {
                case .success(let data):
                    let aaa = self.convertToDictionary(data: data)
                    print(aaa)
                    do{
                        let userRequest = try decoder.decode(UserRequest.self, from: data!)
                        print(userRequest)
                        // 해당 class의 user값에 가공된 데이터를 넣어준다.
                        if userRequest.token != nil {
                            self.user = userRequest
                            
                            // 인코더를 가져와서
                            let encoder = JSONEncoder()
                            // class의 user값이 인코딩이 가능하면
                            if let encoded = try? encoder.encode(self.user) {
                                // 인코딩된 user값은 UserDefaults에 저장한다.
                                UserDefaults.standard.set(encoded, forKey: "user")
                                // 로그인이 되었다고 알려준다.
                                self.isLogin = true
                                result(true, nil)
                            } else {
                                self.isLogin = false
                                result(false, UserError(description: NSLocalizedString("유저 데이터를 인코딩하는 과정에서 문제가 생겼습니다.",comment: "")))
                            }
                        } else {
                            self.isLogin = false
                            result(false, UserError(description: NSLocalizedString("유저 정보가 받아지지 않았습니다.",comment: "")))
                        }
                    } catch(let error) {
                        result(false, error)
                    }
                        

                case .failure(let error):
                    result(false, error)
                }
            }
    }
}
