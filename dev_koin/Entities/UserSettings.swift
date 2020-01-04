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
    @Published var isLogin: Bool = false
    
    init() {
        self.login_succeed()
    }
    
    func remove_user() {
        self.user = nil
    }
    
    func login_succeed() {
        if let data = UserDefaults.standard.object(forKey:"user") as? Data {
            let decoder = JSONDecoder()
            if let loaded = try? decoder.decode(UserRequest.self, from: data) {
                self.user = loaded
                self.isLogin = true
            }
        }
    }
    
    func logout_session() {
        UserDefaults.standard.set(nil, forKey: "user")
        self.user = nil
        self.isLogin = false
    }
    
    func login_session(email: String, password: String) {
        let inputData = Data(password.utf8)
        let hashed = SHA256.hash(data: inputData)
        let hashPassword = hashed.compactMap {String(format: "%02x", $0)}.joined().trimmingCharacters(in: CharacterSet.newlines)
        print("start alamofire")
            Alamofire
            .request("http://api.koreatech.in/user/login", method: .post, parameters:  ["portal_account": email,"password": hashPassword], encoding: JSONEncoding.prettyPrinted)
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
                        print("end alamofire")
                    }
                    
                    
                } catch let error {
                    print(error)
                }
            }
    }
}
