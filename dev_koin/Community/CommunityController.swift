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
    var board_id: Int
    
    let objectWillChange = PassthroughSubject<CommunityController, Never>()
    
    init(board_id: Int) {
        self.articles = Articles()
        self.detail_article = Article()
        self.board_id = board_id
        //self.community_session()
    }
    
    func get_articles() -> [Article] {
        if let articles = self.articles {
            return articles.articles
        }
        return []
    }
    
    func reload_articles() {
        print(self.get_articles().count)
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

    func put_article(token: String = "eyJhbGciOiJIUzI1NiJ9.eyJzdWIiOiIzMTYiLCJleHAiOjE1ODA2NTYxMjF9.4l7puQDosaH2R0p0ISeILQwKLjNamqvYqH3sunPSF3Y", board_id: Int, title: String, content: String, result: @escaping (Bool) -> Void) {
        let headers: HTTPHeaders = [
            "Authorization": "Bearer " + token
        ]
        print("start alamofire")

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
                    print(response)
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
