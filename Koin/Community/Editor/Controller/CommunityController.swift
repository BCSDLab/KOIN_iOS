//
//  CommunityController.swift
//  dev_koin
//
//  Created by 정태훈 on 2020/01/22.
//  Copyright © 2020 정태훈. All rights reserved.
//

import Foundation
import Alamofire
import SwiftUI
import Combine
import PKHUD

class CommunityController: ObservableObject {
    var isTest = CommonVariables.isStage
    
    var api = ""
    var board_id: Int
    
    let objectWillChange = PassthroughSubject<CommunityController, Never>()
    
    struct CommunityError: LocalizedError, Equatable {
        
        private var description: String!
        
        init(description: String) {
            self.description = description
        }
        
        var errorDescription: String? {
            return description
        }
        
        public static func ==(lhs: CommunityError, rhs: CommunityError) -> Bool {
            return lhs.description == rhs.description
        }
    }
    
    init() {
        api = isTest ? "http://stage.api.koreatech.in" : "https://api.koreatech.in"
        self.board_id = -1
        //self.community_session()
    }
    
    init(board_id: Int) {
        api = isTest ? "http://stage.api.koreatech.in" : "https://api.koreatech.in"
        self.board_id = board_id
        //self.community_session()
    }
    
    func convertToDictionary(data: Data?) -> [String: Any]? {
        do {
            return try JSONSerialization.jsonObject(with: data!, options: []) as? [String: Any]
        } catch {
            print(error.localizedDescription)
        }
        return nil
    }
    
    
    func put_temp_article(password: String, title: String, nickname:String, content: String, result: @escaping (Bool, Error?) -> Void) {
        print(content)
        AF
            .request("\(api)/temp/articles", method: .post, parameters: ["password": password, "title": title, "content": content, "nickname": nickname], encoding: JSONEncoding.prettyPrinted)
            .response { response in
                switch response.result {
                    case .success(let data):
                        let data = self.convertToDictionary(data: data)
                        if let status = response.response?.statusCode { // 상태 코드를 가져와서
                            switch(status){
                                case 200:
                                    fallthrough
                                case 201: // 겹치지 않으면(200)
                                    self.objectWillChange.send(self)
                                    result(true, nil) // 겹치지 않는다고 알림
                                    break
                                default: // 겹치거나 오류가 나면
                                    let error = data!["error"] as! [String:Any]
                                    let message = error["message"] as! String
                                    result(false, CommunityError(description: NSLocalizedString(message,comment: ""))) // 겹친다고 알림
                                    break
                            }
                    }
                    case .failure(let error):
                        result(false, error)
                }
        }
        
    }
    
    func put_article(token: String, board_id: Int, title: String, content: String, result: @escaping (Bool, Error?) -> Void) {
        let headers: HTTPHeaders = [
            "Authorization": "Bearer " + token
        ]
        
        AF
            .request("\(api)/articles", method: .post, parameters: ["board_id": board_id, "title": title, "content": content], encoding: JSONEncoding.prettyPrinted, headers: headers)
            .response { response in
                switch response.result {
                    case .success(let data):
                        let data = self.convertToDictionary(data: data)
                        if let status = response.response?.statusCode { // 상태 코드를 가져와서
                            switch(status){
                                case 200:
                                    fallthrough
                                case 201: // 겹치지 않으면(200)
                                    self.objectWillChange.send(self)
                                    result(true, nil) // 겹치지 않는다고 알림
                                    break
                                default: // 겹치거나 오류가 나면
                                    let error = data!["error"] as! [String:Any]
                                    let message = error["message"] as! String
                                    result(false, CommunityError(description: NSLocalizedString(message,comment: ""))) // 겹친다고 알림
                                    break
                            }
                    }
                    case .failure(let error):
                        result(false, error)
                }
        }
    }
    
    func update_temp_article(password: String, article_id: Int, title: String, nickname: String, content: String, result: @escaping (Bool, Error?) -> Void) {
        
        AF
            .request("\(api)/temp/articles/\(article_id)", method: .put, parameters: ["password": password, "title": title, "content": content, "nickname": nickname], encoding: JSONEncoding.prettyPrinted)
            .response { response in
                switch response.result {
                    case .success(let data):
                        let data = self.convertToDictionary(data: data)
                        if let status = response.response?.statusCode { // 상태 코드를 가져와서
                            switch(status){
                                case 200:
                                    fallthrough
                                case 201: // 겹치지 않으면(200)
                                    self.objectWillChange.send(self)
                                    break
                                default: // 겹치거나 오류가 나면
                                    let error = data!["error"] as! [String:Any]
                                    let message = error["message"] as! String
                                    result(false, CommunityError(description: NSLocalizedString(message,comment: ""))) // 겹친다고 알림
                                    break
                            }
                    }
                    case .failure(let error):
                        result(false, error)
                }
        }
    }
    
    func update_article(token: String, article_id: Int, board_id: Int, title: String, content: String, result: @escaping (Bool, Error?) -> Void) {
        let headers: HTTPHeaders = [
            "Authorization": "Bearer " + token
        ]
        
        AF
            .request("\(api)/articles/\(article_id)", method: .put, parameters: ["board_id": board_id, "title": title, "content": content], encoding: JSONEncoding.prettyPrinted, headers: headers)
            .response { response in
                switch response.result {
                    case .success(let data):
                        let data = self.convertToDictionary(data: data)
                        if let status = response.response?.statusCode { // 상태 코드를 가져와서
                            switch(status){
                                case 200:
                                    fallthrough
                                case 201: // 겹치지 않으면(200)
                                    self.objectWillChange.send(self)
                                    break
                                default: // 겹치거나 오류가 나면
                                    let error = data!["error"] as! [String:Any]
                                    let message = error["message"] as! String
                                    result(false, CommunityError(description: NSLocalizedString(message,comment: ""))) // 겹친다고 알림
                                    break
                            }
                    }
                    case .failure(let error):
                        result(false, error)
                }
        }
    }
    
    func grant_article_check(password: String, article_id: Int, result: @escaping (Bool, Error?) -> Void) {
        
        AF
            .request("\(api)/temp/articles/grant/check", method: .post, parameters: ["article_id": article_id, "password": password], encoding: JSONEncoding.prettyPrinted)
            .response { response in
                switch response.result {
                    case .success(let data):
                        let data = self.convertToDictionary(data: data)
                        if let status = response.response?.statusCode { // 상태 코드를 가져와서
                            switch(status){
                                case 200:
                                    fallthrough
                                case 201: // 겹치지 않으면(200)
                                    let a = data!["grantEdit"]
                                    let b = a as! Int
                                    if(b == 1) {
                                        result(true, nil)
                                    } else {
                                        result(false, nil)
                                    }
                                    break
                                default: // 겹치거나 오류가 나면
                                    let error = data!["error"] as! [String:Any]
                                    let message = error["message"] as! String
                                    result(false, CommunityError(description: NSLocalizedString(message,comment: ""))) // 겹친다고 알림
                                    break
                            }
                    }
                    case .failure(let error):
                        result(false, error)
                }
        }
    }
    
}
