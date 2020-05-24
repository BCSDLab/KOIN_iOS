//
//  CommunityDetailViewModel.swift
//  Koin
//
//  Created by 정태훈 on 2020/04/06.
//  Copyright © 2020 정태훈. All rights reserved.
//

import Foundation
import SwiftUI
import Combine
import Firebase
import FirebaseFirestoreSwift
import CryptoKit
import CryptoTokenKit

class CommunityDetailViewModel<T: CommonArticle, C: CommonComment>: ObservableObject, Identifiable {
    var viewDismissalModePublisher = PassthroughSubject<Bool, Never>()

    func hashed(pw: String) -> String {
        // 비밀번호를 먼전 Data로 변환하여
        let inputData = Data(pw.utf8)
        // SHA256을 이용해 해시 처리한 다음
        let hashed = SHA256.hash(data: inputData)
        // 해시 당 16진수 2자리로 설정하여 합친다.
        let hashPassword = hashed.compactMap {
            String(format: "%02x", $0)
        }.joined().trimmingCharacters(in: CharacterSet.newlines)
        return hashPassword
    }

    let headerString = "<header><meta name='viewport' content='width=device-width, initial-scale=1.0'></header>"
    let styleString = """
                          <style type='text/css'>
                              img {
                                  max-width: 100%;
                              }
                              body {
                                  font-family: -apple-system, BlinkMacSystemFont, sans-serif;
                              }
                              
                              </style>
                      <body>
                      """

    @Published var item: T = T()
    @Published var password: String = ""
    private let communityFetcher: CommunityFetchable

    private var disposables = Set<AnyCancellable>()
    var article: Int
    var token: String
    var granted: Bool = false
    @Published var block: [Int] = []
    
    let htmlView = HTMLView()
    @Published var passwordGranted: Bool = false
    
    init(communityFetcher: CommunityFetcher,token: String, articleId: Int, userId: Int) {
        self.token = token
        self.article = articleId
        self.communityFetcher = communityFetcher
        if (T.self == Article.self) {
            self.grantCheck()
        }
    }
    
    private var shouldDismissView = false {
        didSet {
            viewDismissalModePublisher.send(shouldDismissView)
        }
    }
    
    func dateToString(string_date: String) -> String {
        let dateFormat = DateFormatter()
        dateFormat.dateFormat = "yyyy-MM-dd HH:mm:ss"
        let date = dateFormat.date(from: string_date)
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy.MM.dd"
        let dateString = dateFormatter.string(from: date!)
        return dateString
    }
    
    var id: Int {
        return item.id
    }
    
    var boardId: Int {
        if(T.self == Article.self) {
            let i = item as! Article
            return i.boardId
        } else {
            return 0
        }
    }
    
    var title: String {
        return item.title
    }
    
    var commentCount: Int {
        return item.commentCount ?? 0
    }
    
    var hit: Int {
        return item.hit
    }
    
    var nickname: String {
        return item.nickname
    }
    
    var createdAt: String {
        return dateToString(string_date: item.createdAt)
    }

    @Published var content: String = ""
    
    var comments: [C]? {
        return item.comments as? [C]
    }
    
    var html: HTMLView {
        htmlView.loadHTML(content)
        return htmlView
    }
    
    func fetchDetailCommunity() {
        communityFetcher.Community(article: article)
        .receive(on: DispatchQueue.main)
    .sink(
        receiveCompletion: { [weak self] value in
            guard let self = self else { return }
            switch value {
                case .failure:
                    self.item = T()
                case .finished:
                    break
            }
        },
        receiveValue: { [weak self] community in
            guard let self = self else { return }
            var item = community
            //self.item = community as! T
            var filteredComments: [Comment] = []
            for c in item.comments! {
                print(c)
                if (!self.block.contains(c.id)) {
                    filteredComments.append(c)
                }
            }
            item.comments = filteredComments
            self.item = item as! T
            self.content = self.headerString + self.styleString + (item.content ?? "") + "</body>"
            //self.htmlView.loadHTML(community.content ?? "")
        })
        .store(in: &disposables)
    }
    
    func fetchAnonymousDetailCommunity() {
        communityFetcher.AnonymousCommunity(article: article)
            .receive(on: DispatchQueue.main)
            .sink(
                receiveCompletion: { [weak self] value in
                    guard let self = self else { return }
                    switch value {
                        case .failure:
                            self.item = T()
                        case .finished:
                            break
                    }
                },
                receiveValue: { [weak self] community in
                    guard let self = self else { return }
                    //self.item = community as! T
                    var item = community
                    //self.item = community as! T
                    var filteredComments: [TempComment] = []
                    for c in item.comments! {
                        if (!self.block.contains(c.id)) {
                            filteredComments.append(c)
                        }
                    }
                    item.comments = filteredComments
                    self.item = item as! T
                    self.content = self.headerString + self.styleString + (item.content ?? "") + "</body>"
                    //self.htmlView.loadHTML(community.content ?? "")
                })
            .store(in: &disposables)
    }
    
    func declarationArticle(type: String) {
        Firestore.firestore().collection("Article").addDocument(data:
            [
                "type": type,
                "board_id": boardId,
                "article_id": id,
                "user_nickname": nickname,
                "article_title": title,
                "article_content": content
            ]
        )
    }
    
    func loadBlockComment(userId: Int) {
        item.comments = nil
        let userRef = Firestore.firestore().collection("Block").document("\(userId)")
        userRef.getDocument { (document, error) in
            if let document = document, document.exists {
                var data: [Int] = []
                if (T.self == Article.self) {
                    data = document.data()?["Comment"] as? [Int] ?? []
                    print(data)
                    self.block = data
                    self.fetchDetailCommunity()
                } else {
                   data = document.data()?["TempComment"] as? [Int] ?? []
                    self.block = data
                    self.fetchAnonymousDetailCommunity()
                }
            } else {
                print("not exist")
                if (T.self == Article.self) {
                    self.fetchDetailCommunity()
                } else {
                    self.fetchAnonymousDetailCommunity()
                }
            }
        }
    }
    
    func blockArticle(userId: Int) {
        let userRef = Firestore.firestore().collection("Block").document("\(userId)")
        userRef.getDocument { (document, error) in
            if let document = document, document.exists {
                if (T.self == Article.self) {
                    userRef.updateData([
                        "Article": FieldValue.arrayUnion([self.id])
                    ]){ err in
                        if let err = err {
                            print("Error writing document: \(err)")
                        } else {
                            print("Document successfully written!")
                        }
                    }
                } else {
                    userRef.updateData([
                        "TempArticle": FieldValue.arrayUnion([self.id])
                    ]){ err in
                        if let err = err {
                            print("Error writing document: \(err)")
                        } else {
                            print("Document successfully written!")
                        }
                    }
                }
            } else {
                if (T.self == Article.self) {
                    userRef.setData([
                        "Article": [self.id]
                    ]){ err in
                        if let err = err {
                            print("Error writing document: \(err)")
                        } else {
                            print("Document successfully written!")
                        }
                    }
                } else {
                    userRef.setData([
                        "TempArticle": [self.id]
                    ]){ err in
                        if let err = err {
                            print("Error writing document: \(err)")
                        } else {
                            print("Document successfully written!")
                        }
                    }
                }
            }
        }
    }
    
    func grantCheck(){
        communityFetcher.GrantUserCheck(token: token, article: article)
            .receive(on: DispatchQueue.main)
            .sink(
                receiveCompletion: { [weak self] value in
                    guard let self = self else { return }
                },
                receiveValue: { [weak self] receive in
                    guard let self = self else { return }
                    //checked = receive.grantEdit
                    print(receive.grantEdit)
                    self.granted = receive.grantEdit
            })
            .store(in: &disposables)
    }
    
    func passwordCheck(forPassword password: String) {
        communityFetcher.GrantPasswordCheck(password: hashed(pw: password), article: id)
            .receive(on: DispatchQueue.main)
            .sink(
                receiveCompletion: { [weak self] value in
                    guard let self = self else { return }
                    switch value {
                        case .failure:
                            self.password = ""
                        case .finished:
                            break
                    }
                },
                receiveValue: { [weak self] receive in
                    guard let self = self else { return }
                    self.passwordGranted = receive.grantEdit
            })
            .store(in: &disposables)
    }
    
    func passwordGrant(forPassword password: String, result: @escaping (Bool) -> Void){
        //var checked: Bool = false
        communityFetcher.GrantPasswordCheck(password: hashed(pw: password), article: id)
            .receive(on: DispatchQueue.main)
            .sink(
                receiveCompletion: { [weak self] value in
                    guard let self = self else { return }
                },
                receiveValue: { [weak self] receive in
                    guard let self = self else { return }
                    self.passwordGranted = receive.grantEdit
                    result(receive.grantEdit)
            })
    }
    
    func deleteCommunity() {
        communityFetcher.DeleteCommunity(token: token, article: id)
            .receive(on: DispatchQueue.main)
            .sink(
                receiveCompletion: { [weak self] value in
                    guard let self = self else { return }
                },
                receiveValue: { [weak self] receive in
                    guard let self = self else { return }
                    self.shouldDismissView = true
            })
            .store(in: &disposables)
    }
    
    func deleteAnonymousCommunity() {
        communityFetcher.DeleteAnonymous(password: hashed(pw: password), article: id)
            .receive(on: DispatchQueue.main)
            .sink(
                receiveCompletion: { [weak self] value in
                    guard let self = self else { return }
                },
                receiveValue: { [weak self] receive in
                    guard let self = self else { return }
                    self.shouldDismissView = true
            })
            .store(in: &disposables)
    }
    
}

extension CommunityDetailViewModel: Hashable {
    static func == (lhs: CommunityDetailViewModel, rhs: CommunityDetailViewModel) -> Bool {
        return lhs.id == rhs.id
    }
    func hash(into hasher: inout Hasher) {
        hasher.combine(self.id)
    }
}
