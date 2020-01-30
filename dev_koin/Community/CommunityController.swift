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
    
    
    func community_session() {
            Alamofire
            .request("http://stage.api.koreatech.in/articles?boardId=1&page=1&limit=30", method: .get, encoding: JSONEncoding.prettyPrinted)
            .validate { request, response, data in
                return .success
            }
            .response { response in
                guard let data = response.data else { return }
                
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
