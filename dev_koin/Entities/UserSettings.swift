//
//  UserSettings.swift
//  dev_koin
//
//  Created by 정태훈 on 2019/12/24.
//  Copyright © 2019 정태훈. All rights reserved.
//

import SwiftUI
import Alamofire
import ObjectMapper
import AlamofireObjectMapper
import CryptoKit
import CryptoTokenKit
import Foundation

class UserSettings: ObservableObject {
    @Published var user: UserRequest? = nil
    @Published var userInfo: [String: String] = [:]
    @Published var isLogin: Bool = false
    @Published var isChanged: Bool = false
    
    init() {
        self.login_succeed()
    }
    
    func remove_user() {
        self.user = nil
    }
    
    func check_valid_password(password: String, valid_password: String) -> Bool {
        
        let hashPassword = hashed(pw: password)
        
        let hashValidPassword = hashed(pw: valid_password)
        
        if hashPassword == hashValidPassword {
            return true
        } else {
            return false
        }
    }
    
    func get_token() -> String {
        if let user = self.user {
            if let token = user.token {
                return token
            }
        }
        return ""
    }
    
    func hashed(pw: String) -> String{
        let inputData = Data(pw.utf8)
        let hashed = SHA256.hash(data: inputData)
        let hashPassword = hashed.compactMap {String(format: "%02x", $0)}.joined().trimmingCharacters(in: CharacterSet.newlines)
        return hashPassword
    }
    
    func update_data(token: String) {
        let headers = [
            "Authorization": "Bearer " + token
        ]
        print("start alamofire")
        
        Alamofire
        .request("http://stage.api.koreatech.in/user/me", method: .put, encoding: JSONEncoding.prettyPrinted, headers: headers)
        .validate { request, response, data in
            return .success
        }
        .response { response in
            guard let data = response.data else { return }
            do {
                let decoder = JSONDecoder()
                let user = try decoder.decode(User.self, from: data)
                

                
                self.user?.user = user

                print(self.user)
                
                let encoder = JSONEncoder()
                if let encoded = try? encoder.encode(self.user) {
                    UserDefaults.standard.set(encoded, forKey: "user")
                    print("end alamofire")
                }
                
                
            } catch let error {
                print(error)
            }
            
        }
    }
    
    func school_number_to_major(school_number: String) -> String {
        let indexStartOfText = school_number.index(school_number.startIndex, offsetBy: 4)
        let indexEndOfText = school_number.index(school_number.endIndex, offsetBy: -3)
        let substring = school_number[indexStartOfText..<indexEndOfText]
        print(school_number.prefix(4))
        print(substring)
        
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
    
    func update_session(token: String, updated_password: String = "", updated_name: String = "", updated_nickname: String = "", updated_gender: Int = -1, updated_isGraduated: Bool = false, updated_studentNumber: String = "", updated_phoneNumber: String = "", changed_name: Bool = false, changed_gender: Bool = false, changed_phoneNumber: Bool = false, changed_studentNumber: Bool = false, changed_nickname: Bool = false, result: @escaping (Bool) -> Void) {
        
        var parameters: [String: Any] = [:]
        print("START : \(parameters)")
        print(updated_nickname)
        print(changed_nickname)
        if !updated_password.isEmpty {parameters["password"] = hashed(pw: updated_password)}
        if !updated_name.isEmpty && changed_name {parameters["name"] = updated_name}
        if !updated_nickname.isEmpty && changed_nickname {parameters["nickname"] = updated_nickname}
        if updated_gender != -1 && changed_gender {parameters["gender"] = updated_gender}
        if updated_isGraduated {parameters["is_graduated"] = updated_isGraduated}
        if !updated_studentNumber.isEmpty && changed_studentNumber {
            parameters["student_number"] = updated_studentNumber
            parameters["major"] = self.school_number_to_major(school_number: updated_studentNumber)
        }
        if !updated_phoneNumber.isEmpty && changed_phoneNumber {parameters["phone_number"] = updated_phoneNumber}
        print("End : \(parameters)")
                    
                    let headers = [
                        "Authorization": "Bearer " + token
                    ]
                    print("start alamofire")
                    
                    Alamofire
                    .request("http://stage.api.koreatech.in/user/me", method: .put, parameters:  parameters, encoding: JSONEncoding.prettyPrinted, headers: headers)
                    .validate { request, response, data in
                        return .success
                    }
                    .response { response in
                        guard let data = response.data else { return }
                        do {
                            let decoder = JSONDecoder()
                            let user = try decoder.decode(User.self, from: data)
                            
                            print(user)
                            
                            self.user?.user = user
                            
                            let encoder = JSONEncoder()
                            if let encoded = try? encoder.encode(self.user) {
                                UserDefaults.standard.set(encoded, forKey: "user")
                                print("end alamofire")
                                self.isChanged = true
                                result(true)
                            }
                            
                            
                        } catch let error {
                            result(false)
                            print(error)
                        }
                        
                    }
        
    }
    
    func register_session(email: String, password: String, result: @escaping (Bool) -> Void) {
        let hashPassword = hashed(pw: password)
        print(hashPassword)
            Alamofire
            .request("http://stage.api.koreatech.in/user/register", method: .post, parameters:  ["portal_account": email, "password": hashPassword], encoding: JSONEncoding.prettyPrinted)
            .validate { request, response, data in
                return .success
            }
            .responseJSON { response in
                if let status = response.response?.statusCode {
                                switch(status){
                                case 201:
                                    result(true)
                                    
                                default:
                                    print("error with response status: \(status)")
                                    result(false)
                                }
                            }
                        if let result = response.result.value {
                            let JSON = result as! NSDictionary
                            print(JSON["error"])
                            print(JSON["success"])
                        }
                
            }
    }
    
    func login_succeed() {
        print("login start")
        if let data = UserDefaults.standard.object(forKey:"user") as? Data {
            let decoder = JSONDecoder()
            if let loaded = try? decoder.decode(UserRequest.self, from: data) {
                if loaded.token != nil {
                    self.user = loaded
                    print(self.user)
                    self.isLogin = true
                }
                
            }
        }
    }
    
    func delete_session(token: String) {
        let headers = [
            "Authorization": "Bearer "+token
        ]
        print("start alamofire")
        
        Alamofire
        .request("http://stage.api.koreatech.in/user/me", method: .delete, encoding: URLEncoding.httpBody,headers: headers)
        .validate { request, response, data in
            return .success
        }
        .response { response in
            print(response.data!)
            UserDefaults.standard.set(nil, forKey: "user")
            self.user = nil
            self.isLogin = false
        }
    }
    
    func logout_session() {
        UserDefaults.standard.set(nil, forKey: "user")
        self.user = nil
        self.isLogin = false
    }
    
    func login_session(email: String, password: String) {
        let hashPassword = hashed(pw: password)
        print("start alamofire")
            Alamofire
            .request("http://stage.api.koreatech.in/user/login", method: .post, parameters:  ["portal_account": email,"password": hashPassword], encoding: JSONEncoding.prettyPrinted)
            .validate { request, response, data in
                return .success
            }
            .response { response in
                guard let data = response.data else { return }
                do {
                    let decoder = JSONDecoder()
                    let userRequest = try decoder.decode(UserRequest.self, from: data)
                    self.user = userRequest
                    
                    let encoder = JSONEncoder()
                    if let encoded = try? encoder.encode(self.user) {
                        UserDefaults.standard.set(encoded, forKey: "user")
                        self.isLogin = true
                        print("end alamofire")
                    }
                    
                    
                } catch let error {
                    print(error)
                }
            }
    }
}
