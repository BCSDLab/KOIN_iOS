//
//  SearchFetcher.swift
//  Koin
//
//  Created by 정태훈 on 2020/04/28.
//  Copyright © 2020 정태훈. All rights reserved.
//

import Foundation
import Combine

protocol SearchFetchable {
    func searchArticle(
        forQuery query: String
    ) -> AnyPublisher<SearchResponse, SearchError>
}

class SearchFetcher {
    let isStage: Bool = CommonVariables.isStage
    private let session: URLSession
    
    init(session: URLSession = .shared) {
        self.session = session
    }
}

extension SearchFetcher: SearchFetchable {
    func searchArticle(
        forQuery query: String
    ) -> AnyPublisher<SearchResponse, SearchError> {
        return search(with: makeArticleSearchComponents(withQuery: query))
    }
    
    private func search<T>(
        with components: URLComponents
    ) -> AnyPublisher<T, SearchError> where T: Decodable {
        guard let url = components.url else {
            let error = SearchError.network(description: "Couldn't create URL")
            return Fail(error: error).eraseToAnyPublisher()
        }
        return session.dataTaskPublisher(for: URLRequest(url: url))
            .mapError { error in
                print(error)
                return SearchError.network(description: error.localizedDescription)
        }
    .print()
        .flatMap(maxPublishers: .max(1)) { pair in
            decode(pair.data)
        }
            .print()
        .eraseToAnyPublisher()
    }
}

private extension SearchFetcher {
    struct SearchAPI {
        static let scheme = "https"
        static let stageScheme = "http"
        static let productionHost = "api.koreatech.in"
        static let stageHost = "stage.api.koreatech.in"
        static let articlePath = "/articles/search"
        static let shopPath = "/shops/search"
    }
    
    func makeArticleSearchComponents(withQuery query: String, page: Int = 1, limit: Int = 10, searchType: Int = 0) -> URLComponents {
        var components = URLComponents()
        components.scheme = isStage ? SearchAPI.stageScheme : SearchAPI.scheme
        components.host = isStage ? SearchAPI.stageHost : SearchAPI.productionHost
        components.path = SearchAPI.articlePath
        
        components.queryItems = [
            URLQueryItem(name: "page", value: String(page)),
            URLQueryItem(name: "limit", value: String(limit)),
            URLQueryItem(name: "searchType", value: String(searchType)),
            URLQueryItem(name: "query", value: query)
        ]
        return components
    }
}
