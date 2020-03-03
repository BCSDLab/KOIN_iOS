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
    @Published var articles: Articles?
    @Published var detail_article: Article
    @Published var temp_articles: TempArticles?
    @Published var detail_temp_article: TempArticle
    var board_id: Int
    //temporary community는 board_id를 -2로 설정
    
    let objectWillChange = PassthroughSubject<CommunityController, Never>()
    
    init(board_id: Int) {
        print(board_id)
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
    //만약 페이지 초과할 때 조치 방법 생각
    func reload_temp_articles() {
        //print(self.get_temp_articles().count)
        AF
            .request("http://stage.api.koreatech.in/temp/articles?&page=\(self.get_temp_articles().count/30 + 1)&limit=30", method: .get, encoding: JSONEncoding.prettyPrinted)
            
        .response { response in
            guard let data = response.data else {
                return
            }
            do {
                let decoder = JSONDecoder()
                let communityArticles = try decoder.decode(TempArticles.self, from: data)
                for article in communityArticles.articles {
                    self.temp_articles?.articles.append(article)
                }
                self.objectWillChange.send(self)

            } catch let error {
                print(error)
            }

        }
    }
    
    func reload_articles() {
        print(self.board_id)
        AF
            .request("http://stage.api.koreatech.in/articles?boardId=\(self.board_id)&page=\(self.get_articles().count/30 + 1)&limit=30", method: .get, encoding: JSONEncoding.prettyPrinted)
        .response { response in
            guard let data = response.data else {
                return
            }
            do {
                let decoder = JSONDecoder()
                let communityArticles = try decoder.decode(Articles.self, from: data)
                for article in communityArticles.articles {
                    self.articles?.articles.append(article)
                }
                self.objectWillChange.send(self)

            } catch let error {
                print(error)
            }

        }
    }

    func load_temp_community(article_id: Int){
        AF
                .request("http://stage.api.koreatech.in/temp/articles/\(article_id)", method: .get, encoding: JSONEncoding.prettyPrinted)
                .response { response in
                    guard let data = response.data else {
                        return
                    }
                    do {
                        let decoder = JSONDecoder()
                        let articleRequest = try decoder.decode(TempArticle.self, from: data)
                        print(articleRequest)
                        self.detail_temp_article = articleRequest
                        print(self.detail_temp_article)
                        self.objectWillChange.send(self)

                    } catch let error {
                        print(error)
                    }

                }

    }
    
    func load_community(article_id: Int){
        AF
                .request("http://stage.api.koreatech.in/articles/\(article_id)", method: .get, encoding: JSONEncoding.prettyPrinted)
                .response { response in
                    guard let data = response.data else {
                        return
                    }
                    do {
                        let decoder = JSONDecoder()
                        let articleRequest = try decoder.decode(Article.self, from: data)
                        self.detail_article = articleRequest
                        //print(self.detail_article)
                        self.objectWillChange.send(self)

                    } catch let error {
                        print(error)
                    }

                }

    }
    
    func put_temp_article(password: String, title: String, nickname:String, content: String, result: @escaping (Bool) -> Void) {
        AF
            .request("http://stage.api.koreatech.in/temp/articles", method: .post, parameters: ["password": password, "title": title, "content": content, "nickname": nickname], encoding: JSONEncoding.prettyPrinted)
                .responseJSON { response in
                    if let status = response.response?.statusCode { // 상태 코드를 받아서
                        print(status)
                                    switch(status){
                                    case 201: // 잘 받아졌을 때(201)
                                        result(true) // 회원가입이 잘 되었다고 알리고
                                        
                                    default: // 잘 안 받아졌을 때
                                        result(false) // 회원가입이 안 되었다고 알림
                                    }
                                }
                }

    }

    func put_article(token: String, board_id: Int, title: String, content: String, result: @escaping (Bool) -> Void) {
        let headers: HTTPHeaders = [
            "Authorization": "Bearer " + token
        ]
        print("put article")
        print([token, board_id, title, content])

        AF
                .request("http://stage.api.koreatech.in/articles", method: .post, parameters: ["board_id": board_id, "title": title, "content": content], encoding: JSONEncoding.prettyPrinted, headers: headers)
                .responseJSON { response in
                    if let status = response.response?.statusCode { // 상태 코드를 받아서
                        print(status)
                                    switch(status){
                                    case 201: // 잘 받아졌을 때(201)
                                        result(true) // 회원가입이 잘 되었다고 알리고
                                        
                                    default: // 잘 안 받아졌을 때
                                        result(false) // 회원가입이 안 되었다고 알림
                                    }
                                }
                }

    }
    
    func delete_temp_article(password: String, article_id: Int, result: @escaping (Bool) -> Void) {
        let headers: HTTPHeaders = [
            "password": password
        ]
        print("start alamofire")

        AF
                .request("http://stage.api.koreatech.in/temp/articles/\(article_id)", method: .delete, encoding: URLEncoding.httpBody, headers: headers)
                .responseJSON { response in
                    if let status = response.response?.statusCode { // 상태 코드를 받아서
                    print(status)
                                switch(status){
                                case 200: // 잘 받아졌을 때(200)
                                    result(true) // 회원가입이 잘 되었다고 알리고
                                    
                                default: // 잘 안 받아졌을 때
                                    result(false) // 회원가입이 안 되었다고 알림
                                }
                            }
                }
    }

    func delete_article(token: String = "eyJhbGciOiJIUzI1NiJ9.eyJzdWIiOiIzMTYiLCJleHAiOjE1ODA2NTYxMjF9.4l7puQDosaH2R0p0ISeILQwKLjNamqvYqH3sunPSF3Y", article_id: Int, result: @escaping (Bool) -> Void) {
        let headers: HTTPHeaders = [
            "Authorization": "Bearer " + token
        ]
        print("start alamofire")

        AF
                .request("http://stage.api.koreatech.in/articles/\(article_id)", method: .delete, encoding: URLEncoding.httpBody, headers: headers)
                .responseJSON { response in
                    if let status = response.response?.statusCode { // 상태 코드를 받아서
                    print(status)
                                switch(status){
                                case 200: // 잘 받아졌을 때(200)
                                    result(true) // 회원가입이 잘 되었다고 알리고
                                    
                                default: // 잘 안 받아졌을 때
                                    result(false) // 회원가입이 안 되었다고 알림
                                }
                            }
                }
    }
    
    func update_temp_article(password: String, article_id: Int, title: String, content: String, result: @escaping (Bool) -> Void) {
        print("start alamofire")

        AF
                .request("http://stage.api.koreatech.in/temp/articles/\(article_id)", method: .put, parameters: ["password": password, "title": title, "content": content], encoding: JSONEncoding.prettyPrinted)
                .responseJSON { response in
                    if let status = response.response?.statusCode { // 상태 코드를 받아서
                    print(response)
                                switch(status){
                                case 201: // 잘 받아졌을 때(201)
                                    
                                    result(true) // 회원가입이 잘 되었다고 알리고
                                    self.load_temp_community(article_id: article_id)
                                    self.objectWillChange.send(self)
                                    
                                default: // 잘 안 받아졌을 때
                                    result(false) // 회원가입이 안 되었다고 알림
                                }
                            }
                }
    }

    func update_article(token: String = "eyJhbGciOiJIUzI1NiJ9.eyJzdWIiOiIzMTYiLCJleHAiOjE1ODA2NTYxMjF9.4l7puQDosaH2R0p0ISeILQwKLjNamqvYqH3sunPSF3Y", article_id: Int, board_id: Int, title: String, content: String, result: @escaping (Bool) -> Void) {
        let headers: HTTPHeaders = [
            "Authorization": "Bearer " + token
        ]
        print("start alamofire")
        print(content)

        AF
                .request("http://stage.api.koreatech.in/articles/\(article_id)", method: .put, parameters: ["board_id": board_id, "title": title, "content": content], encoding: JSONEncoding.prettyPrinted, headers: headers)
                .responseJSON { response in
                    if let status = response.response?.statusCode { // 상태 코드를 받아서
                    print(status)
                                switch(status){
                                case 201: // 잘 받아졌을 때(201)
                                    result(true) // 회원가입이 잘 되었다고 알리고
                                    self.load_community(article_id: article_id)
                                    self.objectWillChange.send(self)
                                    
                                default: // 잘 안 받아졌을 때
                                    result(false) // 회원가입이 안 되었다고 알림
                                }
                            }
                }
    }
    
    func put_temp_comment(password: String, article_id: Int, nickname:String, content: String, result: @escaping (Bool) -> Void) {
        print("start alamofire")

        AF
            .request("http://stage.api.koreatech.in/temp/articles/\(article_id)/comments", method: .post, parameters: ["content": content, "nickname": nickname,
                                                                                                                       "password": password], encoding: JSONEncoding.prettyPrinted)
                .responseJSON { response in
                    if let status = response.response?.statusCode { // 상태 코드를 받아서
                    print(status)
                                switch(status){
                                case 201: // 잘 받아졌을 때(201)
                                    result(true) // 회원가입이 잘 되었다고 알리고
                                    self.load_temp_community(article_id: article_id)
                                    self.objectWillChange.send(self)
                                default: // 잘 안 받아졌을 때
                                    result(false) // 회원가입이 안 되었다고 알림
                                }
                            }
                }

    }

    func put_comment(token: String = "eyJhbGciOiJIUzI1NiJ9.eyJzdWIiOiIzMTYiLCJleHAiOjE1ODA2NTYxMjF9.4l7puQDosaH2R0p0ISeILQwKLjNamqvYqH3sunPSF3Y", article_id: Int, content: String, result: @escaping (Bool) -> Void) {
        let headers: HTTPHeaders = [
            "Authorization": "Bearer " + token
        ]
        print("start alamofire")

        AF
                .request("http://stage.api.koreatech.in/articles/\(article_id)/comments", method: .post, parameters: ["content": content], encoding: JSONEncoding.prettyPrinted, headers: headers)
                .responseJSON { response in
                    if let status = response.response?.statusCode { // 상태 코드를 받아서
                    print(status)
                                switch(status){
                                case 201: // 잘 받아졌을 때(201)
                                    result(true) // 회원가입이 잘 되었다고 알리고
                                    self.load_community(article_id: article_id)
                                    self.objectWillChange.send(self)
                                default: // 잘 안 받아졌을 때
                                    result(false) // 회원가입이 안 되었다고 알림
                                }
                            }
                }

    }
    
    func delete_temp_comment(password: String, article_id: Int, comment_id: Int, result: @escaping (Bool) -> Void) {
        let headers: HTTPHeaders = [
            "password": password
        ]
        print("start alamofire")

        AF
                .request("http://stage.api.koreatech.in/temp/articles/\(article_id)/comments/\(comment_id)", method: .delete, encoding: URLEncoding.httpBody, headers: headers)
                .responseJSON { response in
                    if let status = response.response?.statusCode { // 상태 코드를 받아서
                    print(status)
                                switch(status){
                                case 200: // 잘 받아졌을 때(200)
                                    result(true) // 회원가입이 잘 되었다고 알리고
                                    self.load_temp_community(article_id: article_id)
                                    self.objectWillChange.send(self)
                                    
                                default: // 잘 안 받아졌을 때
                                    result(false) // 회원가입이 안 되었다고 알림
                                }
                            }
                }
    }

    func delete_comment(token: String = "eyJhbGciOiJIUzI1NiJ9.eyJzdWIiOiIzMTYiLCJleHAiOjE1ODA2NTYxMjF9.4l7puQDosaH2R0p0ISeILQwKLjNamqvYqH3sunPSF3Y", article_id: Int, comment_id: Int, result: @escaping (Bool) -> Void) {
        let headers: HTTPHeaders = [
            "Authorization": "Bearer " + token
        ]
        print("start alamofire")

        AF
                .request("http://stage.api.koreatech.in//articles/\(article_id)/comments/\(comment_id)", method: .delete, encoding: URLEncoding.httpBody, headers: headers)
                .responseJSON { response in
                    if let status = response.response?.statusCode { // 상태 코드를 받아서
                    print(status)
                                switch(status){
                                case 200: // 잘 받아졌을 때(200)
                                    result(true) // 회원가입이 잘 되었다고 알리고
                                    self.load_community(article_id: article_id)
                                    self.objectWillChange.send(self)
                                    
                                default: // 잘 안 받아졌을 때
                                    result(false) // 회원가입이 안 되었다고 알림
                                }
                            }
                }
    }
    
    func update_temp_comment(password: String, article_id: Int, comment_id: Int, content: String, result: @escaping (Bool) -> Void) {        print("start alamofire")

        AF
            .request("http://stage.api.koreatech.in/temp/articles/\(article_id)/comments/\(comment_id)", method: .put, parameters: ["content": content, "password": password], encoding: JSONEncoding.prettyPrinted)
                .responseJSON { response in
                    if let status = response.response?.statusCode { // 상태 코드를 받아서
                    print(status)
                                switch(status){
                                case 201: // 잘 받아졌을 때(201)
                                    result(true) // 회원가입이 잘 되었다고 알리고
                                    self.load_temp_community(article_id: article_id)
                                    self.objectWillChange.send(self)
                                default: // 잘 안 받아졌을 때
                                    result(false) // 회원가입이 안 되었다고 알림
                                }
                            }
                }
    }
    
    /*
     //가능
     success({
         grantEdit = 1;
     })
     //불가능
     success({
         grantEdit = 0;
     })
     
     */
    
    func grant_article_check(password: String, article_id: Int, result: @escaping (AFResult<[String: Any]>) -> Void) {
        print("start alamofire")

        AF
            .request("http://stage.api.koreatech.in/temp/articles/grant/check", method: .post, parameters: ["article_id": article_id, "password": password], encoding: JSONEncoding.prettyPrinted)
                .responseJSON { response in
                    switch response.result {
                    case .success(let value as [String: Any]):
                        result(.success(value))
                    case .failure(let error):
                        result(.failure(error))
                    default:
                        fatalError("received non-dictionary JSON response")
                    }
                }
    }
    
    func grant_comment_check(password: String, comment_id: Int, result: @escaping (AFResult<[String: Any]>) -> Void){
        print("start alamofire")

        AF
            .request("http://stage.api.koreatech.in/temp/comments/grant/check", method: .post, parameters: ["comment_id": comment_id, "password": password], encoding: JSONEncoding.prettyPrinted)
                .responseJSON { response in
                    switch response.result {
                    case .success(let value as [String: Any]):
                        result(.success(value))
                    case .failure(let error):
                        result(.failure(error))
                    default:
                        fatalError("received non-dictionary JSON response")
                    }
                    
                    
                }
    }

    func update_comment(token: String = "eyJhbGciOiJIUzI1NiJ9.eyJzdWIiOiIzMTYiLCJleHAiOjE1ODA2NTYxMjF9.4l7puQDosaH2R0p0ISeILQwKLjNamqvYqH3sunPSF3Y", article_id: Int, comment_id: Int, content: String, result: @escaping (Bool) -> Void) {
        let headers: HTTPHeaders = [
            "Authorization": "Bearer " + token
        ]
        print("start alamofire")

        AF
                .request("http://stage.api.koreatech.in/articles/\(article_id)/comments/\(comment_id)", method: .put, parameters: ["content": content], encoding: JSONEncoding.prettyPrinted, headers: headers)
                .responseJSON { response in
                    if let status = response.response?.statusCode { // 상태 코드를 받아서
                    print(status)
                                switch(status){
                                case 201: // 잘 받아졌을 때(201)
                                    result(true) // 회원가입이 잘 되었다고 알리고
                                    self.load_community(article_id: article_id)
                                    self.objectWillChange.send(self)
                                default: // 잘 안 받아졌을 때
                                    result(false) // 회원가입이 안 되었다고 알림
                                }
                            }
                }
    }

    func temp_community_session() {
        AF
                .request("http://stage.api.koreatech.in/temp/articles?page=1&limit=30", method: .get, encoding: JSONEncoding.prettyPrinted)
                .response { response in
                    guard let data = response.data else {
                        return
                    }
                
                do {
                    let decoder = JSONDecoder()
                    let communityArticles = try decoder.decode(TempArticles.self, from: data)
                    
                    self.temp_articles = communityArticles
                    self.objectWillChange.send(self)
                    
                    
                } catch let error {
                    print(error)
                }
                
            }
    }

    func community_session() {
        AF
                .request("http://stage.api.koreatech.in/articles?boardId=\(self.board_id)&page=1&limit=30", method: .get, encoding: JSONEncoding.prettyPrinted)
                .response { response in
                    guard let data = response.data else {
                        return
                    }
                
                do {
                    let decoder = JSONDecoder()
                    let communityArticles = try decoder.decode(Articles.self, from: data)
                    
                    self.articles = communityArticles
                    self.objectWillChange.send(self)
                    
                    
                } catch let error {
                    print(error)
                }
                
            }
    }
}
