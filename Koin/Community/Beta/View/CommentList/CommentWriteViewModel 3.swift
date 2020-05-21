//
//  CommentWriteViewModel.swift
//  Koin
//
//  Created by 정태훈 on 2020/04/10.
//  Copyright © 2020 정태훈. All rights reserved.
//

import Foundation
import Combine

class CommentWriteViewModel: ObservableObject, Identifiable {
    private let communityFetcher: CommunityFetchable
    
    private var disposables = Set<AnyCancellable>()
    
    private var article: Article
    
    private var token: String
    
    @Published var content: String = ""
    
    private var comment: Comment? = nil
    
    init(token: String, article: Article) {
        self.communityFetcher = CommunityFetcher()
        self.token = token
        self.article = article
    }
    
    func loadComment(comment: Comment) {
        self.comment = comment
    }
    
    func deleteComment(comment: Int) {
        communityFetcher.DeleteComment(token: token, article: article.id, comment: comment)
            .receive(on: DispatchQueue.main)
            .sink(
                receiveCompletion: { [weak self] value in
                    guard let self = self else { return }
                    print(value)
                    /*
                    switch value {
                        case .failure:
                            self.dataSource = []
                        case .finished:
                            break
                    }
                    */
                },
                receiveValue: { [weak self] receive in
                    guard let self = self else { return }
                    print(receive)
            })
            .store(in: &disposables)
    }
    
    func putComment(content: String) {
        communityFetcher.PutComment(token: token, article: article.id, content: "content")
            .receive(on: DispatchQueue.main)
            .sink(
                receiveCompletion: { [weak self] value in
                    guard let self = self else { return }
                    print(value)/*
                    switch value {
                        case .failure:
                            self.dataSource = []
                        case .finished:
                            break
                    }*/
                },
                receiveValue: { [weak self] receive in
                    guard let self = self else { return }
                    print(receive)
                    
            })
            .store(in: &disposables)
    }
    
    func updateComment(comment: Int, content: String) {
        communityFetcher.UpdateComment(token: token, article: article.id, comment: comment, content: content)
            .receive(on: DispatchQueue.main)
            .sink(
                receiveCompletion: { [weak self] value in
                    guard let self = self else { return }
                    print(value)/*
                    switch value {
                        case .failure:
                            self.dataSource = []
                        case .finished:
                            break
                    }*/
                },
                receiveValue: { [weak self] receive in
                    guard let self = self else { return }
                    print(receive)
            })
            .store(in: &disposables)
    }
    
}
