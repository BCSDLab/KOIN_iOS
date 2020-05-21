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
    
    @Published var articles: Articles?
    @Published var detail_article: Article
    @Published var temp_articles: TempArticles?
    @Published var detail_temp_article: TempArticle
    var board_id: Int
    //temporary community는 board_id를 -2로 설정
    
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
        self.articles = Articles()
        self.detail_article = Article()
        self.board_id = -1
        //self.community_session()
        self.temp_articles = TempArticles()
        self.detail_temp_article = TempArticle()
    }
    
    init(board_id: Int) {
        api = isTest ? "http://stage.api.koreatech.in" : "https://api.koreatech.in"
        self.articles = Articles()
        self.detail_article = Article()
        self.board_id = board_id
        //self.community_session()
        self.temp_articles = TempArticles()
        self.detail_temp_article = TempArticle()
    }
    
    func get_temp_articles() -> [TempArticle] {
        if let articles = self.temp_articles {
            return articles.articles
        }
        return []
    }
    
    func get_articles() -> [Article] {
        if let articles = self.articles {
            return articles.articles
        }
        return []
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
    
    //만약 페이지 초과할 때 조치 방법 생각
    func reload_temp_articles(result: @escaping (Bool, Error?) -> Void) {
        AF
            .request("\(api)/temp/articles?&page=\(self.get_temp_articles().count/10 + 1)&limit=10", method: .get, encoding: JSONEncoding.prettyPrinted)
        .response { response in
            
            switch response.result {
                case .success(let data):
                    do{
                        let decoder = JSONDecoder()
                        let communityArticles = try decoder.decode(TempArticles.self, from: data!)
                        for article in communityArticles.articles {
                           self.temp_articles?.articles.append(article)
                        }
                        self.objectWillChange.send(self)
                        result(true, nil)
                    } catch(let error) {
                        result(false, error)
                }
                case .failure(let error):
                    result(false, error)
            }
        }
    }
    
    func reload_articles(result: @escaping (Bool, Error?) -> Void) {
        AF
            .request("\(api)/articles?boardId=\(self.board_id)&page=\(self.get_articles().count/10 + 1)&limit=10", method: .get, encoding: JSONEncoding.prettyPrinted)
        .response { response in
            
            switch response.result {
                case .success(let data):
                    do{
                        let decoder = JSONDecoder()
                        let communityArticles = try decoder.decode(Articles.self, from: data!)
                        for article in communityArticles.articles {
                            self.articles?.articles.append(article)
                        }
                        self.objectWillChange.send(self)
                        result(true, nil)
                    } catch(let error) {
                        result(false, error)
                }
                case .failure(let error):
                    result(false, error)
            }
        }
    }

    func load_temp_community(article_id: Int, result: @escaping (Bool, Error?) -> Void){
        AF
                .request("\(api)/temp/articles/\(article_id)", method: .get, encoding: JSONEncoding.prettyPrinted)
                .response { response in
                    switch response.result {
                        case .success(let data):
                            do{
                                let decoder = JSONDecoder()
                                let articleRequest = try decoder.decode(TempArticle.self, from: data!)
                                self.detail_temp_article = articleRequest
                                self.objectWillChange.send(self)
                                result(true, nil)
                            } catch(let error) {
                                result(false, error)
                        }
                        case .failure(let error):
                            result(false, error)
                    }
                }

    }
    
    func load_community(article_id: Int, result: @escaping (Bool, Error?) -> Void){
        AF
                .request("\(api)/articles/\(article_id)", method: .get, encoding: JSONEncoding.prettyPrinted)
                .response { response in
                    switch response.result {
                        case .success(let data):
                            do{
                                let decoder = JSONDecoder()
                                let articleRequest = try decoder.decode(Article.self, from: data!)
                                self.detail_article = articleRequest
                                self.objectWillChange.send(self)
                                result(true, nil)
                            } catch(let error) {
                                result(false, error)
                        }
                        case .failure(let error):
                            result(false, error)
                    }

                }

    }
    
    func put_temp_article(password: String, title: String, nickname:String, content: String, result: @escaping (Bool, Error?) -> Void) {
        AF
            .request("\(api)/temp/articles", method: .post, parameters: ["password": password, "title": title, "content": content, "nickname": nickname], encoding: JSONEncoding.prettyPrinted)
                .response { response in
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
                        print(data)
                        if let status = response.response?.statusCode { // 상태 코드를 가져와서
                            print(status)
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
    
    func delete_temp_article(password: String, article_id: Int, result: @escaping (Bool, Error?) -> Void) {
        let headers: HTTPHeaders = [
            "password": password
        ]

        AF
                .request("\(api)/temp/articles/\(article_id)", method: .delete, encoding: URLEncoding.httpBody, headers: headers)
                .response { response in
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

    func delete_article(token: String, article_id: Int, result: @escaping (Bool, Error?) -> Void) {
        let headers: HTTPHeaders = [
            "Authorization": "Bearer " + token
        ]

        AF
                .request("\(api)/articles/\(article_id)", method: .delete, encoding: URLEncoding.httpBody, headers: headers)
                .response { response in
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
                        print(data)
                        if let status = response.response?.statusCode { // 상태 코드를 가져와서
                            print(status)
                            switch(status){
                            case 200:
                                fallthrough
                            case 201: // 겹치지 않으면(200)
                                self.objectWillChange.send(self)
                                self.load_temp_community(article_id: article_id) { (loaded, error) in
                                    if loaded {
                                        result(true, nil)
                                    } else {
                                        result(false, error)
                                    }
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
                        print(data)
                        if let status = response.response?.statusCode { // 상태 코드를 가져와서
                            print(status)
                            switch(status){
                            case 200:
                                fallthrough
                            case 201: // 겹치지 않으면(200)
                                self.objectWillChange.send(self)
                                self.load_community(article_id: article_id) { (loaded, error) in
                                    if loaded {
                                        result(true, nil)
                                    } else {
                                        result(false, error)
                                    }
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
    
    func put_temp_comment(password: String, article_id: Int, nickname:String, content: String, result: @escaping (Bool, Error?) -> Void) {

        AF
            .request("\(api)/temp/articles/\(article_id)/comments", method: .post, parameters: ["content": content, "nickname": nickname,
                                                                                                                       "password": password], encoding: JSONEncoding.prettyPrinted)
                .response { response in
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
                                self.objectWillChange.send(self)
                                self.load_temp_community(article_id: article_id) { (loaded, error) in
                                    if loaded {
                                        result(true, nil)
                                    } else {
                                        result(false, error)
                                    }
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

    func put_comment(token: String, article_id: Int, content: String, result: @escaping (Bool, Error?) -> Void) {
        print(content)
        let headers: HTTPHeaders = [
            "Authorization": "Bearer " + token
        ]

        AF
                .request("\(api)/articles/\(article_id)/comments", method: .post, parameters: ["content": content], encoding: JSONEncoding.prettyPrinted, headers: headers)
                .response { response in
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
                                self.objectWillChange.send(self)
                                self.load_community(article_id: article_id) { (loaded, error) in
                                    if loaded {
                                        result(true, nil)
                                    } else {
                                        result(false, error)
                                    }
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
    
    func delete_temp_comment(password: String, article_id: Int, comment_id: Int, result: @escaping (Bool, Error?) -> Void) {
        let headers: HTTPHeaders = [
            "password": password
        ]

        AF
                .request("\(api)/temp/articles/\(article_id)/comments/\(comment_id)", method: .delete, encoding: URLEncoding.httpBody, headers: headers)
                .response { response in
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
                                self.objectWillChange.send(self)
                                self.load_temp_community(article_id: article_id) { (loaded, error) in
                                    if loaded {
                                        result(true, nil)
                                    } else {
                                        result(false, error)
                                    }
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

    func delete_comment(token: String, article_id: Int, comment_id: Int, result: @escaping (Bool, Error?) -> Void) {
        let headers: HTTPHeaders = [
            "Authorization": "Bearer " + token
        ]

        AF
                .request("\(api)/articles/\(article_id)/comments/\(comment_id)", method: .delete, encoding: URLEncoding.httpBody, headers: headers)
                .response { response in
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
                                self.objectWillChange.send(self)
                                self.load_community(article_id: article_id) { (loaded, error) in
                                    if loaded {
                                        result(true, nil)
                                    } else {
                                        result(false, error)
                                    }
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
    
    func update_temp_comment(password: String, article_id: Int, comment_id: Int, content: String, result: @escaping (Bool, Error?) -> Void) {

        AF
            .request("\(api)/temp/articles/\(article_id)/comments/\(comment_id)", method: .put, parameters: ["content": content, "password": password], encoding: JSONEncoding.prettyPrinted)
                .response { response in
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
                                self.objectWillChange.send(self)
                                self.load_temp_community(article_id: article_id) { (loaded, error) in
                                    if loaded {
                                        result(true, nil)
                                    } else {
                                        result(false, error)
                                    }
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
    
    
    func grant_article_check(password: String, article_id: Int, result: @escaping (Bool, Error?) -> Void) {

        AF
            .request("\(api)/temp/articles/grant/check", method: .post, parameters: ["article_id": article_id, "password": password], encoding: JSONEncoding.prettyPrinted)
                .response { response in
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
                                let a = data!["grantEdit"]
                                let b = a as! Int
                                print(a)
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
    
    func grant_comment_check(password: String, comment_id: Int, result: @escaping (Bool, Error?) -> Void){

        AF
            .request("\(api)/temp/comments/grant/check", method: .post, parameters: ["comment_id": comment_id, "password": password], encoding: JSONEncoding.prettyPrinted)
                .response { response in
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
                                result(false, CommunityError(description: NSLocalizedString(message,comment: ""))) // 겹친다고 알림
                                break
                            }
                        }
                    case .failure(let error):
                        result(false, error)
                    }
                }
    }

    func update_comment(token: String, article_id: Int, comment_id: Int, content: String, result: @escaping (Bool, Error?) -> Void) {
        let headers: HTTPHeaders = [
            "Authorization": "Bearer " + token
        ]

        AF
                .request("\(api)/articles/\(article_id)/comments/\(comment_id)", method: .put, parameters: ["content": content], encoding: JSONEncoding.prettyPrinted, headers: headers)
                .response { response in
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
                                self.objectWillChange.send(self)
                                self.load_community(article_id: article_id) { (loaded, error) in
                                    if loaded {
                                        result(true, nil)
                                    } else {
                                        result(false, error)
                                    }
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

    func temp_community_session(result: @escaping (Bool, Error?) -> Void) {
        AF
                .request("\(api)/temp/articles?page=1&limit=10", method: .get, encoding: JSONEncoding.prettyPrinted)
                .response { response in
                    switch response.result {
                        case .success(let data):
                            do{
                                let decoder = JSONDecoder()
                                let communityArticles = try decoder.decode(TempArticles.self, from: data!)
                                self.temp_articles = communityArticles
                                self.objectWillChange.send(self)
                                result(true, nil)
                            } catch(let error) {
                                result(false, error)
                        }
                        case .failure(let error):
                            result(false, error)
                    }
            }
    }

    func community_session(result: @escaping (Bool, Error?) -> Void) {
        AF
                .request("\(api)/articles?boardId=\(self.board_id)&page=1&limit=10", method: .get, encoding: JSONEncoding.prettyPrinted)
                .response { response in
                    switch response.result {
                        case .success(let data):
                            do{
                                let decoder = JSONDecoder()
                                let communityArticles = try decoder.decode(Articles.self, from: data!)
                                self.articles = communityArticles
                                self.objectWillChange.send(self)
                                result(true, nil)
                            } catch(let error) {
                                result(false, error)
                        }
                        case .failure(let error):
                            result(false, error)
                    }
            }
    }
}
