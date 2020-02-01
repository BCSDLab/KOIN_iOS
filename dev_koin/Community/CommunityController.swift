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
    
    let objectWillChange = PassthroughSubject<CommunityController, Never>()
    
    init() {
        self.articles = Articles()
        self.detail_article = Article()
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
        Alamofire
        .request("http://stage.api.koreatech.in/articles?boardId=1&page=\(self.get_articles().count/30 + 1)&limit=30", method: .get, encoding: JSONEncoding.prettyPrinted)
        .validate { request, response, data in
            return .success
        }
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
        Alamofire
                .request("http://stage.api.koreatech.in/articles/\(article_id)", method: .get, encoding: JSONEncoding.prettyPrinted)
                .validate { request, response, data in
                    return .success
                }
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

    func put_article(token: String = "eyJhbGciOiJIUzI1NiJ9.eyJzdWIiOiIzMTYiLCJleHAiOjE1ODA2NTYxMjF9.4l7puQDosaH2R0p0ISeILQwKLjNamqvYqH3sunPSF3Y", board_id: Int, title: String, content: String) {
        let headers = [
            "Authorization": "Bearer " + token
        ]
        print("start alamofire")

        Alamofire
                .request("http://stage.api.koreatech.in/articles", method: .post, parameters: ["board_id": board_id, "title": title, "content": content], encoding: JSONEncoding.prettyPrinted, headers: headers)
                .validate { request, response, data in
                    return .success
                }
                .responseJSON { response in
                    print(response)
                }

    }

    func delete_article(token: String = "eyJhbGciOiJIUzI1NiJ9.eyJzdWIiOiIzMTYiLCJleHAiOjE1ODA2NTYxMjF9.4l7puQDosaH2R0p0ISeILQwKLjNamqvYqH3sunPSF3Y", article_id: Int) {
        let headers = [
            "Authorization": "Bearer " + token
        ]
        print("start alamofire")

        Alamofire
                .request("http://stage.api.koreatech.in/articles/\(article_id)", method: .delete, encoding: URLEncoding.httpBody, headers: headers)
                .validate { request, response, data in
                    return .success
                }
                .responseJSON { response in
                    print(response)
                }
    }

    func update_article(token: String = "eyJhbGciOiJIUzI1NiJ9.eyJzdWIiOiIzMTYiLCJleHAiOjE1ODA2NTYxMjF9.4l7puQDosaH2R0p0ISeILQwKLjNamqvYqH3sunPSF3Y", article_id: Int, board_id: Int, title: String, content: String) {
        let headers = [
            "Authorization": "Bearer " + token
        ]
        print("start alamofire")

        Alamofire
                .request("http://stage.api.koreatech.in/articles/\(article_id)", method: .put, parameters: ["board_id": board_id, "title": title, "content": content], encoding: JSONEncoding.prettyPrinted, headers: headers)
                .validate { request, response, data in
                    return .success
                }
                .responseJSON { response in
                    print(response)
                }
    }

    func put_comment(token: String = "eyJhbGciOiJIUzI1NiJ9.eyJzdWIiOiIzMTYiLCJleHAiOjE1ODA2NTYxMjF9.4l7puQDosaH2R0p0ISeILQwKLjNamqvYqH3sunPSF3Y", article_id: Int, content: String) {
        let headers = [
            "Authorization": "Bearer " + token
        ]
        print("start alamofire")

        Alamofire
                .request("http://stage.api.koreatech.in/articles/\(article_id)/comments", method: .post, parameters: ["content": content], encoding: JSONEncoding.prettyPrinted, headers: headers)
                .validate { request, response, data in
                    return .success
                }
                .responseJSON { response in
                    print(response)
                }

    }

    func delete_comment(token: String = "eyJhbGciOiJIUzI1NiJ9.eyJzdWIiOiIzMTYiLCJleHAiOjE1ODA2NTYxMjF9.4l7puQDosaH2R0p0ISeILQwKLjNamqvYqH3sunPSF3Y", article_id: Int, comment_id: Int) {
        let headers = [
            "Authorization": "Bearer " + token
        ]
        print("start alamofire")

        Alamofire
                .request("http://stage.api.koreatech.in//articles/\(article_id)/comments/\(comment_id)", method: .delete, encoding: URLEncoding.httpBody, headers: headers)
                .validate { request, response, data in
                    return .success
                }
                .responseJSON { response in
                    print(response)
                }
    }

    func update_comment(token: String = "eyJhbGciOiJIUzI1NiJ9.eyJzdWIiOiIzMTYiLCJleHAiOjE1ODA2NTYxMjF9.4l7puQDosaH2R0p0ISeILQwKLjNamqvYqH3sunPSF3Y", article_id: Int, comment_id: Int, content: String) {
        let headers = [
            "Authorization": "Bearer " + token
        ]
        print("start alamofire")

        Alamofire
                .request("http://stage.api.koreatech.in/articles/\(article_id)/comments/\(comment_id)", method: .put, parameters: ["content": content], encoding: JSONEncoding.prettyPrinted, headers: headers)
                .validate { request, response, data in
                    return .success
                }
                .responseJSON { response in
                    print(response)
                }
    }


    func community_session() {
        Alamofire
                .request("http://stage.api.koreatech.in/articles?boardId=1&page=1&limit=30", method: .get, encoding: JSONEncoding.prettyPrinted)
                .validate { request, response, data in
                    return .success
                }
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
