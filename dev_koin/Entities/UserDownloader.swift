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
    @Published var userData: UserData?
    
    init() {
        userData = nil
    }
    
    func request(email: String, hash_password: String){
        var login_success: Bool = false
        
        do {
        AF.request("http://api.koreatech.in/user/login", method: .post, parameters:  ["portal_account": email,"password": hash_password], encoder: JSONParameterEncoder.default).response { response in
            switch response.result {
            case .success(let value):
                guard let data = value else { return }
                self.userData = try! JSONDecoder().decode(UserData.self, from: data)
                login_success = true
            case .failure( _):
                login_success = false
            }
        }
        }
        
    }
    
    func login_session(email: String, password: String){
        
        let inputData = Data(password.utf8)
        let hashed = SHA256.hash(data: inputData)
        let hashString = hashed.compactMap {String(format: "%02x", $0)}.joined().trimmingCharacters(in: CharacterSet.newlines)
            
        request(email: email, hash_password: hashString)
        
    }
}

