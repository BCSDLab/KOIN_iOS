//
//  UserDownloader.swift
//  dev_koin
//
//  Created by 정태훈 on 2019/12/15.
//  Copyright © 2019 정태훈. All rights reserved.
//
import SwiftUI
import Alamofire
import ObjectMapper
import AlamofireObjectMapper
import CryptoKit
import CryptoTokenKit
import Foundation
import UIKit

class UserDownloader: ObservableObject {
    @Published var userData: UserRequest? = nil
    
    public init() {
        self.userData = nil
    }
    
    func setUser(email: String, password: String) {
        login_session(email: email, password: password) { user in
            self.userData = user
        }
    }
    
    func isUser() -> Bool {
        if self.userData == nil {
            return false
        }
        return true
    }
    
    func getUserInfo() -> [String] {
        if let user = self.userData {
            if let userinfo = user.user {
                return [userinfo.portalAccount, userinfo.name, userinfo.nickname, userinfo.anonymousNickname, userinfo.phoneNumber, userinfo.gender == 0 ? "남자":"여자", userinfo.studentNumber, userinfo.major]
            }
        }
        return ["error"]
    }
    
    func login_session(email: String, password: String, completion: @escaping (UserRequest?) -> Void) {
        let inputData = Data(password.utf8)
        let hashed = SHA256.hash(data: inputData)
        let hashPassword = hashed.compactMap {String(format: "%02x", $0)}.joined().trimmingCharacters(in: CharacterSet.newlines)
        do {
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
                    completion(userRequest)
                } catch let error {
                    print(error)
                    completion(nil)
                }
            }
        }
    }
    
}

