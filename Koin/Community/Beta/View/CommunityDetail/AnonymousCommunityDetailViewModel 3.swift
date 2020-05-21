//
//  AnonymousCommunityDetailViewModel.swift
//  Koin
//
//  Created by 정태훈 on 2020/04/14.
//  Copyright © 2020 정태훈. All rights reserved.
//
/*
import Foundation
import SwiftUI
import Combine
import Firebase
import FirebaseFirestoreSwift

class AnonymousCommunityDetailViewModel : ObservableObject, Identifiable {
    
    var viewDismissalModePublisher = PassthroughSubject<Bool, Never>()
    
    @Published var item: TempArticle = TempArticle()
    private let communityFetcher: CommunityFetchable
    
    internal var disposables = Set<AnyCancellable>()
    var article: Int
    @Published var password: String = ""
    var granted: Bool = false
    
    init(communityFetcher: CommunityFetcher, articleId: Int) {
        self.communityFetcher = communityFetcher
        self.article = articleId
    }
    
    internal var shouldDismissView = false {
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
    
    var content: String {
        return item.content ?? ""
    }
    
    var comments: [TempComment] {
        return item.comments ?? []
    }
    
    var html: HTMLView {
        let html = HTMLView()
        html.loadHTML(item.content ?? "")
        return html
    }
    
    func fetchAnonymousDetailCommunity() {
        communityFetcher.AnonymousCommunity(article: article)
            .receive(on: DispatchQueue.main)
            .sink(
                receiveCompletion: { [weak self] value in
                    guard let self = self else { return }
                    print(value)
                    switch value {
                        case .failure:
                            self.item = TempArticle()
                        case .finished:
                            break
                    }
                },
                receiveValue: { [weak self] community in
                    guard let self = self else { return }
                    print(community)
                    self.item = community
            })
            .store(in: &disposables)
    }
    
    func declarationArticle(type: String) {
        Firestore.firestore().collection("Article").addDocument(data:
            [
                "type": type,
                "board_id": 0,
                "article_id": id,
                "user_nickname": nickname,
                "article_title": title,
                "article_content": content
            ]
        )
    }
    
    func deleteAnonymousCommunity() {
        communityFetcher.DeleteAnonymous(password: password, article: id)
            .receive(on: DispatchQueue.main)
            .sink(
                receiveCompletion: { [weak self] value in
                    guard let self = self else { return }
                    print(value)
                },
                receiveValue: { [weak self] receive in
                    guard let self = self else { return }
                    print(receive)
                    self.shouldDismissView = true
            })
            .store(in: &disposables)
    }
    
}

extension AnonymousCommunityDetailViewModel: Hashable {
    static func == (lhs: AnonymousCommunityDetailViewModel, rhs: AnonymousCommunityDetailViewModel) -> Bool {
        return lhs.id == rhs.id
    }
    func hash(into hasher: inout Hasher) {
        hasher.combine(self.id)
    }
}
*/
