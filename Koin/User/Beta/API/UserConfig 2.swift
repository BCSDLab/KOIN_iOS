//
//  StartViewModel.swift
//  Koin
//
//  Created by 정태훈 on 2020/05/13.
//  Copyright © 2020 정태훈. All rights reserved.
//

import SwiftUI
import CryptoKit
import CryptoTokenKit
import Foundation
import Combine

class UserConfig: ObservableObject {
    @Published var isLogin = false
    @Published var user: UserData? = nil
    
    init() {
        loadUser()
        hasUser = check_token(token: user?.token ?? "")
    }
    
    var name: String {
        return user?.user?.name ?? ""
    }
    
    var nickname: String {
        return user?.user?.nickname ?? ""
    }
    
    var id: Int {
        return user?.user?.id ?? -1
    }
    
    var gender: Int {
        return user?.user?.gender ?? -1
    }
    
    var major: String {
        return user?.user?.major ?? ""
    }
    
    var phoneNumber: String {
        return user?.user?.phoneNumber ?? ""
    }
    
    var portalAccount: String {
        return user?.user?.portalAccount ?? ""
    }
    
    var studentNumber: String {
        return user?.user?.studentNumber ?? ""
    }
    
    var userName: String {
        return user?.user?.username ?? ""
    }
    
    var token: String {
        return user?.token ?? ""
    }
    
    @Published var hasUser: Bool = false
    
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
    
    func saveUser(user: UserData) {
        let encoder = JSONEncoder()
        do {
            let encoded = try encoder.encode(user)
            UserDefaults.standard.set(encoded, forKey: "user")
        } catch(let error) {
            print(error)
            isLogin = false
        }
    }
    
    func updateUser(user: UserData) {
        self.user = user
        saveUser(user: user)
    }
    
    func checkUser(user: UserData) {
        if let t = user.token {
            if check_token(token: t) {
                // user(UserRequest)에 가공된 값을 저장하고
                self.user = user
                saveUser(user: user)
                // 로그인이 되었다고 알림
                self.isLogin = true
                print("true")
            } else {
                print("???")
                logoutUser()
            }
        }
    }
    
    func loadUser() {
        if let data = UserDefaults.standard.object(forKey:"user") as? Data {
            // 디코더를 가져와서
            let decoder = JSONDecoder()
            // 해당 값을 UserReqeust 형태로 가공해서
            do {
                let loaded = try decoder.decode(UserData.self, from: data)
                print(loaded)
                // 토큰이 비어있지 않으면
                if let t = loaded.token {
                    if check_token(token: t) {
                        // user(UserRequest)에 가공된 값을 저장하고
                        self.user = loaded
                        // 로그인이 되었다고 알림
                        self.isLogin = true
                        hasUser = true
                    } else {
                        logoutUser()
                    }
                }
            } catch(let error) {
                print(error)
            }
        }
    }
    
    func logoutUser() {
        UserDefaults.standard.set(nil, forKey: "user")
        self.user = nil
        self.isLogin = false
        hasUser = false
    }
    
    func check_token(token: String) -> Bool {
        let d = token.split(separator: ".")
        if d.isEmpty {
            print("isEmpty")
            hasUser = false
            return false
        }
        if let decodedData = Data(base64Encoded: String(d[1])) {
            if let decodedString = String(data: decodedData, encoding: .utf8) {
                let decodedDict = convertToDictionary(text: decodedString)
                if let expTime = decodedDict!["exp"] {
                    print(expTime)
                    let tm = Date(timeIntervalSince1970: expTime as! TimeInterval)
                    if Date() < tm {
                        hasUser = true
                        return true
                    } else {
                        print("exp fail")
                        hasUser = false
                        return false
                    }
                }
                hasUser = false
                print("dict fail")
                return false
            }
            hasUser = false
            print("string fail")
            return false
        }
        hasUser = false
        print("data fail")
        return false
    }
    
    func check_expired() -> Bool {
        return check_token(token: user?.token ?? "")
    }
}
