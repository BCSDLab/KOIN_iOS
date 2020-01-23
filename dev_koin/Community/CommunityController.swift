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
    
    let objectWillChange = PassthroughSubject<CommunityController, Never>()
    
    init() {
        self.articles = Articles()
        //self.community_session()
    }
    
    func get_articles() -> [Article] {
        if let articles = self.articles {
            return articles.articles
        }
        return []
    }
    
    
    func community_session() {
            Alamofire
            .request("http://stage.api.koreatech.in/articles?boardId=1", method: .get, encoding: JSONEncoding.prettyPrinted)
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
