//
//  CommunityFetcher.swift
//  Koin
//
//  Created by 정태훈 on 2020/04/05.
//  Copyright © 2020 정태훈. All rights reserved.
//

import Foundation
import CryptoKit
import CryptoTokenKit
import Combine

protocol CommunityFetchable {
    // MARK: Community
    func CommunityList(boardId: Int, page: Int) -> AnyPublisher<Articles, KoinCommunityError>
    func Community(article: Int) -> AnyPublisher<Article, KoinCommunityError>
    func PutCommunity(token: String, title:String, content:String,boardId: Int, article: Int) -> AnyPublisher<Article, KoinCommunityError>
    func UpdateCommunity(token: String, title:String, content:String,boardId: Int,article: Int) -> AnyPublisher<Article, KoinCommunityError>
    func DeleteCommunity(token: String,article: Int) -> AnyPublisher<CommunityResponse, KoinCommunityError>
    
    func GrantUserCheck(token: String, article: Int) -> AnyPublisher<GrantCheckResponse, KoinCommunityError>
    
    // MARK: AnonymousCommunity
    func AnonymousCommunityList(page: Int) -> AnyPublisher<TempArticles, KoinCommunityError>
    func AnonymousCommunity(article: Int) -> AnyPublisher<TempArticle, KoinCommunityError>
    func PutAnonymous(password: String, title:String, content:String, article: Int) -> AnyPublisher<Article, KoinCommunityError>
    func UpdateAnonymous(password: String, title:String, content:String, article: Int) -> AnyPublisher<Article, KoinCommunityError>
    func DeleteAnonymous(password: String,article: Int) -> AnyPublisher<CommunityResponse, KoinCommunityError>
    func GrantPasswordCheck(password: String, article: Int) -> AnyPublisher<GrantCheckResponse, KoinCommunityError>
    
    // MARK: CommunityComment
    func PutComment(token: String, article: Int, content: String) -> AnyPublisher<Comment, KoinCommunityError>
    func UpdateComment(token: String, article: Int, comment: Int, content: String) -> AnyPublisher<Comment, KoinCommunityError>
    func DeleteComment(token: String, article: Int,comment: Int) -> AnyPublisher<CommunityResponse, KoinCommunityError>
    
    // MARK: AnonymousCommunityComment
    func PutAnonymousComment(password: String, article: Int,nickname:String,  content: String) -> AnyPublisher<TempComment, KoinCommunityError>
    func UpdateAnonymousComment(password: String, article: Int,nickname:String,  comment: Int, content: String) -> AnyPublisher<TempComment, KoinCommunityError>
    func DeleteAnonymousComment(password: String, article: Int,comment: Int) -> AnyPublisher<CommunityResponse, KoinCommunityError>
}

class CommunityFetcher {
    let isStage: Bool = true
    private let session: URLSession
    init(session: URLSession = .shared) {
        self.session = session
    }
}

extension CommunityFetcher: CommunityFetchable{
    
    // MARK: Community
    func CommunityList(boardId: Int, page: Int) -> AnyPublisher<Articles, KoinCommunityError> {
        return getCommunity(with: makeCommunityListComponents(isStage: isStage,WithBoardId: boardId, WithPage: page))
    }
    func Community(article: Int) -> AnyPublisher<Article, KoinCommunityError> {
        return getCommunity(with: makeCommunityComponents(isStage: isStage, WithArticleId: article))
    }
    func PutCommunity(token: String, title:String, content:String, boardId: Int, article: Int) -> AnyPublisher<Article, KoinCommunityError> {
        return setCommunity(with: makePutCommunityRequest(isStage: isStage, WithToken: token, WithBoardId: boardId, WithTitle: "", WithContent: ""))
    }
    func UpdateCommunity(token: String, title:String, content:String,boardId: Int,article: Int) -> AnyPublisher<Article, KoinCommunityError> {
        return setCommunity(with: makeUpdateCommunityRequest(isStage: isStage, WithToken: token, WithBoardId: boardId, WithArticleId: article, WithTitle: title, WithContent: content))
    }
    func DeleteCommunity(token: String,article: Int) -> AnyPublisher<CommunityResponse, KoinCommunityError> {
        return setCommunity(with: makeDeleteCommunityRequest(isStage: isStage, WithToken: token, WithArticleId: article))
    }
    
    func GrantUserCheck(token: String, article: Int) -> AnyPublisher<GrantCheckResponse, KoinCommunityError> {
        return setCommunity(with: makeGrantCheckRequest(isStage: isStage, WithToken: token, WithArticleId: article))
    }
    
    // MARK: AnonymousCommunity
    func AnonymousCommunityList(page: Int) -> AnyPublisher<TempArticles, KoinCommunityError> {
        return getCommunity(with: makeAnonymousListCommunityComponents(isStage: isStage, WithPage: page))
    }
    func AnonymousCommunity(article: Int) -> AnyPublisher<TempArticle, KoinCommunityError> {
        return getCommunity(with: makeAnonymousComponents(isStage: isStage, WithArticleId: article))
    }
    func PutAnonymous(password: String, title:String, content:String, article: Int) -> AnyPublisher<Article, KoinCommunityError> {
        return setCommunity(with: makePutAnonymousRequest(isStage: isStage, WithPassword: password, WithTitle: title, WithContent: content))
    }
    func UpdateAnonymous(password: String, title:String, content:String, article: Int) -> AnyPublisher<Article, KoinCommunityError> {
        return setCommunity(with: makeUpdateAnonymousRequest(isStage: isStage, WithPassword: password, WithArticleId: article, WithTitle: title, WithContent: content))
    }
    func DeleteAnonymous(password: String,article: Int) -> AnyPublisher<CommunityResponse, KoinCommunityError> {
        return setCommunity(with: makeDeleteAnonymousRequest(isStage: isStage, WithPassword: password, WithArticleId: article))
    }
    func GrantPasswordCheck(password: String, article: Int) -> AnyPublisher<GrantCheckResponse, KoinCommunityError> {
        return setCommunity(with: makeGrantPasswordRequest(isStage: isStage, WithPassword: password, WithArticleId: article))
    }
    
    // MARK: CommunityComment
    func PutComment(token: String, article: Int, content: String) -> AnyPublisher<Comment, KoinCommunityError> {
        return setCommunity(with: makePutCommentRequest(isStage: isStage, WithToken: token, WithArticleId: article, WithContent: content))
    }
    func UpdateComment(token: String, article: Int, comment: Int, content: String) -> AnyPublisher<Comment, KoinCommunityError> {
        return setCommunity(with: makeUpdateCommentRequest(isStage: isStage, WithToken: token, WithArticleId: article, WithCommentId: comment, WithContent: content))
    }
    func DeleteComment(token: String, article: Int,comment: Int) -> AnyPublisher<CommunityResponse, KoinCommunityError> {
        return setCommunity(with: makeDeleteCommentRequest(isStage: isStage, WithToken: token, WithArticleId: article, WithCommentId: comment))
    }
    
    // MARK: AnonymousCommunityComment
    func PutAnonymousComment(password: String, article: Int, nickname:String, content: String) -> AnyPublisher<TempComment, KoinCommunityError> {
        return setCommunity(with: makePutAnonymousCommentRequest(isStage: isStage, WithPassword: password, WithArticleId: article, WithNickname: nickname, WithContent: content))
    }
    
    func UpdateAnonymousComment(password: String, article: Int, nickname:String, comment: Int, content: String) -> AnyPublisher<TempComment, KoinCommunityError> {
        return setCommunity(with: makeUpdateAnonymousCommentRequest(isStage: isStage, WithPassword: password, WithArticleId: article, WithNickname: nickname, WithCommentId: comment, WithContent: content))
    }
    
    func DeleteAnonymousComment(password: String, article: Int,comment: Int) -> AnyPublisher<CommunityResponse, KoinCommunityError> {
        return setCommunity(with: makeDeleteAnonymousCommentRequest(isStage: isStage, WithPassword: password, WithArticleId: article, WithCommentId: comment))
    }
    
    // MARK: 게시판 목록, 게시판 불러오는 기능
    private func getCommunity<T>(with components: URLComponents) -> AnyPublisher<T, KoinCommunityError> where T: Decodable {
        guard let url = components.url else {
            let error = KoinCommunityError.network(description: "Couldn't create URL")
            return Fail(error: error).eraseToAnyPublisher()
        }
        
        return session.dataTaskPublisher(for: URLRequest(url: url))
            .mapError { error in
                return KoinCommunityError.network(description: error.localizedDescription)
            }
            .flatMap(maxPublishers: .max(1)) { pair in
                decode(pair.data)
            }
            .eraseToAnyPublisher()
    }
    
    // MARK: 게시판 생성, 수정, 삭제 기능
    private func setCommunity<T>(with community: CommunityRequest) -> AnyPublisher<T, KoinCommunityError> where T: Decodable {
        if community.isError() {
            return Fail(error: community.getError()).eraseToAnyPublisher()
        } else {
            return session.dataTaskPublisher(for: community.getRequest())
                .mapError { error in
                    return KoinCommunityError.network(description: error.localizedDescription)
            }
            .flatMap(maxPublishers: .max(1)) { pair in
                decode(pair.data)
            }
            .eraseToAnyPublisher()
        }
    }
    
}


private extension CommunityFetcher {
    struct CommunityAPI {
        static let scheme = "https"
        static let stageScheme = "http"
        static let productionHost = "api.koreatech.in"
        static let stageHost = "stage.api.koreatech.in"
        static let path = "/articles"
        static let anonymousPath = "/temp/articles"
        static let commentPath = "/comments"
        static let grantPath = "/grant/check"
    }
    
    func makeCommunityListComponents(isStage: Bool, WithBoardId boardId: Int, WithPage page: Int) -> URLComponents {
        var components = URLComponents()
        components.scheme = isStage ? CommunityAPI.stageScheme : CommunityAPI.scheme
        components.host = isStage ? CommunityAPI.stageHost : CommunityAPI.productionHost
        components.path = CommunityAPI.path
        
        components.queryItems = [
            URLQueryItem(name: "boardId", value: String(boardId)),
            URLQueryItem(name: "page", value: String(page)),
            URLQueryItem(name: "limit", value: "10")
        ]
        return components
    }
    
    func makeCommunityComponents(isStage: Bool, WithArticleId articleId: Int) -> URLComponents {
        var components = URLComponents()
        components.scheme = isStage ? CommunityAPI.stageScheme : CommunityAPI.scheme
        components.host = isStage ? CommunityAPI.stageHost : CommunityAPI.productionHost
        components.path = CommunityAPI.path + "/\(articleId)"
        
        return components
    }
    
    func makeGrantCheckComponents(isStage: Bool) -> URLComponents {
        var components = URLComponents()
        components.scheme = isStage ? CommunityAPI.stageScheme : CommunityAPI.scheme
        components.host = isStage ? CommunityAPI.stageHost : CommunityAPI.productionHost
        components.path = CommunityAPI.path + CommunityAPI.grantPath
        
        return components
    }
    
    func makePutCommunityComponents(isStage: Bool) -> URLComponents {
        var components = URLComponents()
        components.scheme = isStage ? CommunityAPI.stageScheme : CommunityAPI.scheme
        components.host = isStage ? CommunityAPI.stageHost : CommunityAPI.productionHost
        components.path = CommunityAPI.path
        
        return components
    }
    
    func makePutCommunityRequest(isStage: Bool, WithToken token: String, WithBoardId boardId: Int, WithTitle title: String, WithContent content: String) -> CommunityRequest {
        let components = makePutCommunityComponents(isStage: isStage)
        
        var request = URLRequest(url: components.url!)
        request.httpMethod = "POST"
        request.setValue("application/json; charset=utf-8", forHTTPHeaderField: "Content-Type")
        request.addValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        
        let parameters: [String: Any] = ["board_id": boardId, "title": title, "content": content]
        
        do {
            request.httpBody = try JSONSerialization.data(withJSONObject: parameters, options: .prettyPrinted)
        } catch let error {
            return CommunityRequest(request: nil, error: KoinCommunityError.network(description: error.localizedDescription))
        }
        return CommunityRequest(request: request, error: nil)
    }
    
    func makeUpdateCommunityRequest(isStage: Bool, WithToken token: String, WithBoardId boardId: Int, WithArticleId articleId: Int, WithTitle title: String, WithContent content: String) -> CommunityRequest {
        let components = makeCommunityComponents(isStage: isStage, WithArticleId: articleId )
        
        var request = URLRequest(url: components.url!)
        request.httpMethod = "PUT"
        request.setValue("application/json; charset=utf-8", forHTTPHeaderField: "Content-Type")
        request.addValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        
        let parameters: [String: Any] = ["board_id": boardId, "title": title, "content": content]
        
        do {
            request.httpBody = try JSONSerialization.data(withJSONObject: parameters, options: .prettyPrinted)
        } catch let error {
            return CommunityRequest(request: nil, error: KoinCommunityError.network(description: error.localizedDescription))
        }
        return CommunityRequest(request: request, error: nil)
    }
    
    func makeDeleteCommunityRequest(isStage: Bool, WithToken token: String, WithArticleId articleId: Int) -> CommunityRequest {
        let components = makeCommunityComponents(isStage: isStage, WithArticleId: articleId )
        
        var request = URLRequest(url: components.url!)
        request.httpMethod = "DELETE"
        request.setValue("application/json; charset=utf-8", forHTTPHeaderField: "Content-Type")
        request.addValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        
        return CommunityRequest(request: request, error: nil)
    }
    
    func makeGrantCheckRequest(isStage: Bool, WithToken token: String, WithArticleId articleId: Int) -> CommunityRequest {
        let components = makeGrantCheckComponents(isStage: isStage)
        
        var request = URLRequest(url: components.url!)
        request.httpMethod = "POST"
        request.setValue("application/json; charset=utf-8", forHTTPHeaderField: "Content-Type")
        request.addValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        
        let parameters: [String: Any] = ["article_id": articleId]
        
        do {
            request.httpBody = try JSONSerialization.data(withJSONObject: parameters, options: .prettyPrinted)
        } catch let error {
            return CommunityRequest(request: nil, error: KoinCommunityError.network(description: error.localizedDescription))
        }
        return CommunityRequest(request: request, error: nil)
    }
    
    func makeAnonymousListCommunityComponents(isStage: Bool, WithPage page: Int) -> URLComponents {
        var components = URLComponents()
        components.scheme = isStage ? CommunityAPI.stageScheme : CommunityAPI.scheme
        components.host = isStage ? CommunityAPI.stageHost : CommunityAPI.productionHost
        components.path = CommunityAPI.anonymousPath
        
        components.queryItems = [
            URLQueryItem(name: "page", value: String(page)),
            URLQueryItem(name: "limit", value: "10")
        ]
        
        return components
    }
    
    func makeAnonymousComponents(isStage: Bool, WithArticleId articleId: Int) -> URLComponents {
        var components = URLComponents()
        components.scheme = isStage ? CommunityAPI.stageScheme : CommunityAPI.scheme
        components.host = isStage ? CommunityAPI.stageHost : CommunityAPI.productionHost
        components.path = CommunityAPI.anonymousPath + "/\(articleId)"
        
        return components
    }
    
    func makePutAnonymousComponents(isStage: Bool) -> URLComponents {
        var components = URLComponents()
        components.scheme = isStage ? CommunityAPI.stageScheme : CommunityAPI.scheme
        components.host = isStage ? CommunityAPI.stageHost : CommunityAPI.productionHost
        components.path = CommunityAPI.anonymousPath
        
        return components
    }
    
    func makeGrantPasswordComponents(isStage: Bool) -> URLComponents {
        var components = URLComponents()
        components.scheme = isStage ? CommunityAPI.stageScheme : CommunityAPI.scheme
        components.host = isStage ? CommunityAPI.stageHost : CommunityAPI.productionHost
        components.path = CommunityAPI.anonymousPath + CommunityAPI.grantPath
        
        return components
    }
    
    func makePutAnonymousRequest(isStage: Bool, WithPassword password: String, WithTitle title: String, WithContent content: String) -> CommunityRequest {
        let components = makePutAnonymousComponents(isStage: isStage)
        
        var request = URLRequest(url: components.url!)
        request.httpMethod = "POST"
        request.setValue("application/json; charset=utf-8", forHTTPHeaderField: "Content-Type")
        request.addValue("\(password)", forHTTPHeaderField: "password")
        
        let parameters: [String: Any] = ["title": title, "content": content]
        
        do {
            request.httpBody = try JSONSerialization.data(withJSONObject: parameters, options: .prettyPrinted)
        } catch let error {
            return CommunityRequest(request: nil, error: KoinCommunityError.network(description: error.localizedDescription))
        }
        return CommunityRequest(request: request, error: nil)
    }
    
    func makeUpdateAnonymousRequest(isStage: Bool, WithPassword password: String, WithArticleId articleId: Int, WithTitle title: String, WithContent content: String) -> CommunityRequest {
        let components = makeAnonymousComponents(isStage: isStage, WithArticleId: articleId )
        
        var request = URLRequest(url: components.url!)
        request.httpMethod = "PUT"
        request.setValue("application/json; charset=utf-8", forHTTPHeaderField: "Content-Type")
        request.addValue("\(password)", forHTTPHeaderField: "password")
        
        let parameters: [String: Any] = ["title": title, "content": content]
        
        do {
            request.httpBody = try JSONSerialization.data(withJSONObject: parameters, options: .prettyPrinted)
        } catch let error {
            return CommunityRequest(request: nil, error: KoinCommunityError.network(description: error.localizedDescription))
        }
        return CommunityRequest(request: request, error: nil)
    }
    
    func makeDeleteAnonymousRequest(isStage: Bool, WithPassword password: String, WithArticleId articleId: Int) -> CommunityRequest {
        let components = makeAnonymousComponents(isStage: isStage, WithArticleId: articleId )
        
        var request = URLRequest(url: components.url!)
        request.httpMethod = "DELETE"
        request.setValue("application/json; charset=utf-8", forHTTPHeaderField: "Content-Type")
        request.addValue("\(password)", forHTTPHeaderField: "password")
        
        return CommunityRequest(request: request, error: nil)
    }
    
    func makeGrantPasswordRequest(isStage: Bool, WithPassword password: String, WithArticleId articleId: Int) -> CommunityRequest {
        let components = makeGrantPasswordComponents(isStage: isStage)
        
        var request = URLRequest(url: components.url!)
        request.httpMethod = "POST"
        request.setValue("application/json; charset=utf-8", forHTTPHeaderField: "Content-Type")
        
        let parameters: [String: Any] = ["article_id": articleId, "password": password]
        
        do {
            request.httpBody = try JSONSerialization.data(withJSONObject: parameters, options: .prettyPrinted)
        } catch let error {
            return CommunityRequest(request: nil, error: KoinCommunityError.network(description: error.localizedDescription))
        }
        return CommunityRequest(request: request, error: nil)
    }
    
    func makeCommentComponents(isStage: Bool, WithArticleId articleId: Int, WithCommentId commentId: Int) -> URLComponents {
        var components = URLComponents()
        components.scheme = isStage ? CommunityAPI.stageScheme : CommunityAPI.scheme
        components.host = isStage ? CommunityAPI.stageHost : CommunityAPI.productionHost
        components.path = CommunityAPI.path + "/\(articleId)" + CommunityAPI.commentPath + "/\(commentId)"
        
        return components
    }
    
    func makePutCommentComponents(isStage: Bool, WithArticleId articleId: Int) -> URLComponents {
        var components = URLComponents()
        components.scheme = isStage ? CommunityAPI.stageScheme : CommunityAPI.scheme
        components.host = isStage ? CommunityAPI.stageHost : CommunityAPI.productionHost
        components.path = CommunityAPI.path + "/\(articleId)" + CommunityAPI.commentPath
        
        return components
    }
    
    func makePutCommentRequest(isStage: Bool, WithToken token: String, WithArticleId articleId: Int, WithContent content: String) -> CommunityRequest {
        let components = makePutCommentComponents(isStage: isStage, WithArticleId: articleId)
        
        var request = URLRequest(url: components.url!)
        request.httpMethod = "POST"
        request.setValue("application/json; charset=utf-8", forHTTPHeaderField: "Content-Type")
        request.addValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        
        let parameters: [String: Any] = ["content": content]
        do {
            request.httpBody = try JSONSerialization.data(withJSONObject: parameters, options: .prettyPrinted)
        } catch let error {
            return CommunityRequest(request: nil, error: KoinCommunityError.network(description: error.localizedDescription))
        }
        return CommunityRequest(request: request, error: nil)
    }
    
    func makeUpdateCommentRequest(isStage: Bool, WithToken token: String, WithArticleId articleId: Int, WithCommentId commentId: Int, WithContent content: String) -> CommunityRequest {
        let components = makeCommentComponents(isStage: isStage, WithArticleId: articleId, WithCommentId: commentId )
        
        var request = URLRequest(url: components.url!)
        request.httpMethod = "PUT"
        request.setValue("application/json; charset=utf-8", forHTTPHeaderField: "Content-Type")
        request.addValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        
        let parameters: [String: Any] = ["content": content]
        
        do {
            request.httpBody = try JSONSerialization.data(withJSONObject: parameters, options: .prettyPrinted)
        } catch let error {
            return CommunityRequest(request: nil, error: KoinCommunityError.network(description: error.localizedDescription))
        }
        return CommunityRequest(request: request, error: nil)
    }
    
    func makeDeleteCommentRequest(isStage: Bool, WithToken token: String, WithArticleId articleId: Int, WithCommentId commentId: Int) -> CommunityRequest {
        let components = makeCommentComponents(isStage: isStage, WithArticleId: articleId, WithCommentId: commentId )
        
        var request = URLRequest(url: components.url!)
        request.httpMethod = "DELETE"
        request.setValue("application/json; charset=utf-8", forHTTPHeaderField: "Content-Type")
        request.addValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        
        return CommunityRequest(request: request, error: nil)
    }
    
    func makeAnonymousCommentComponents(isStage: Bool, WithArticleId articleId: Int, WithCommentId commentId: Int) -> URLComponents {
        var components = URLComponents()
        components.scheme = isStage ? CommunityAPI.stageScheme : CommunityAPI.scheme
        components.host = isStage ? CommunityAPI.stageHost : CommunityAPI.productionHost
        components.path = CommunityAPI.anonymousPath + "/\(articleId)" + CommunityAPI.commentPath + "/\(commentId)"
        
        return components
    }
    
    func makePutAnonymousCommentComponents(isStage: Bool, WithArticleId articleId: Int) -> URLComponents {
        var components = URLComponents()
        components.scheme = isStage ? CommunityAPI.stageScheme : CommunityAPI.scheme
        components.host = isStage ? CommunityAPI.stageHost : CommunityAPI.productionHost
        components.path = CommunityAPI.anonymousPath + "/\(articleId)" + CommunityAPI.commentPath
        
        return components
    }
    
    func makePutAnonymousCommentRequest(isStage: Bool, WithPassword password: String, WithArticleId articleId: Int, WithNickname nickname: String, WithContent content: String) -> CommunityRequest {
        let components = makePutAnonymousCommentComponents(isStage: isStage, WithArticleId: articleId)
        
        var request = URLRequest(url: components.url!)
        request.httpMethod = "POST"
        request.setValue("application/json; charset=utf-8", forHTTPHeaderField: "Content-Type")
        
        let parameters: [String: Any] = ["nickname": nickname, "content": content, "password": password]
        
        do {
            request.httpBody = try JSONSerialization.data(withJSONObject: parameters, options: .prettyPrinted)
        } catch let error {
            return CommunityRequest(request: nil, error: KoinCommunityError.network(description: error.localizedDescription))
        }
        return CommunityRequest(request: request, error: nil)
    }
    
    func makeUpdateAnonymousCommentRequest(isStage: Bool, WithPassword password: String, WithArticleId articleId: Int, WithNickname nickname: String, WithCommentId commentId: Int, WithContent content: String) -> CommunityRequest {
        let components = makeAnonymousCommentComponents(isStage: isStage, WithArticleId: articleId, WithCommentId: commentId )
        
        var request = URLRequest(url: components.url!)
        request.httpMethod = "PUT"
        request.setValue("application/json; charset=utf-8", forHTTPHeaderField: "Content-Type")
        
        let parameters: [String: Any] = ["nickname": nickname, "content": content, "password": password]
        
        do {
            request.httpBody = try JSONSerialization.data(withJSONObject: parameters, options: .prettyPrinted)
        } catch let error {
            return CommunityRequest(request: nil, error: KoinCommunityError.network(description: error.localizedDescription))
        }
        return CommunityRequest(request: request, error: nil)
    }
    
    func makeDeleteAnonymousCommentRequest(isStage: Bool, WithPassword password: String, WithArticleId articleId: Int, WithCommentId commentId: Int) -> CommunityRequest {
        let components = makeAnonymousCommentComponents(isStage: isStage, WithArticleId: articleId, WithCommentId: commentId )
        
        var request = URLRequest(url: components.url!)
        request.httpMethod = "DELETE"
        request.setValue("application/json; charset=utf-8", forHTTPHeaderField: "Content-Type")
        request.addValue("\(password)", forHTTPHeaderField: "password")
        
        return CommunityRequest(request: request, error: nil)
    }
}
