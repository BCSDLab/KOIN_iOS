//
//  CommunityCommentViewModel.swift
//  Koin
//
//  Created by 정태훈 on 2020/04/06.
//  Copyright © 2020 정태훈. All rights reserved.
//

import Foundation
import Combine
import SwiftUI
import CryptoKit
import CryptoTokenKit

class CommunityCommentViewModel<T: CommonArticle, C: CommonComment>: ObservableObject, Identifiable {
    @Published var dataSource: [CommentRowViewModel<C>] = []
    
    private let communityFetcher: CommunityFetchable
    
    private var disposables = Set<AnyCancellable>()
    
    private var comments: [C] = []
    
    var article: T
    
    @Published var tempNickname : String = ""
    
    var token: String
    
    @Published var password: String = ""
    
    var isEdited: Bool = false
    
    var editCommentId: Int = -1
    
    let objectWillChange = PassthroughSubject<CommunityCommentViewModel<T,C>, Never>()
    
    @Published var content: String = ""
    
    func dateToString(string_date: String) -> String {
        let dateFormat = DateFormatter()
        dateFormat.dateFormat = "yyyy-MM-dd HH:mm:ss"
        let date = dateFormat.date(from: string_date)
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy.MM.dd"
        let dateString = dateFormatter.string(from: date!)
        return dateString
    }
    
    func hashed(pw: String) -> String{
        // 비밀번호를 먼전 Data로 변환하여
        let inputData = Data(pw.utf8)
        // SHA256을 이용해 해시 처리한 다음
        let hashed = SHA256.hash(data: inputData)
        // 해시 당 16진수 2자리로 설정하여 합친다.
        let hashPassword = hashed.compactMap {String(format: "%02x", $0)}.joined().trimmingCharacters(in: CharacterSet.newlines)
        return hashPassword
    }
    
    
    var id: Int {
        return article.id
    }
    
    var boardId: Int {
        if(T.self == Article.self) {
            let i = article as! Article
            return i.boardId
        } else {
            return 0
        }
    }
    
    var title: String {
        return article.title
    }
    
    var commentCount: Int {
        return article.commentCount ?? 0
    }
    
    var hit: Int {
        return article.hit
    }
    
    var nickname: String {
        return article.nickname
    }
    
    var createdAt: String {
        return dateToString(string_date: article.createdAt)
    }
    
    
    
    init(token: String, article: T, comments: [C]) {
        self.communityFetcher = CommunityFetcher()
        self.token = token
        self.article = article
        self.comments = comments
        self.dataSource = comments.map { value in
            CommentRowViewModel(item: value, boardId: boardId, articleId: id)
        }
    }
    
    func editComment(id: Int, content: String) {
        self.isEdited = true
        self.editCommentId = id
        self.content = content
        self.objectWillChange.send(self)
    }
    
    func editComment(id: Int, nickname: String, content: String) {
        self.isEdited = true
        self.editCommentId = id
        self.tempNickname = nickname
        self.content = content
        self.objectWillChange.send(self)
    }
    
    func clearComment() {
        self.isEdited = false
        self.editCommentId = -1
        self.tempNickname = ""
        self.content = ""
        self.password = ""
        self.objectWillChange.send(self)
    }
    
    
    func deleteComment() {
        communityFetcher.DeleteComment(token: token, article: article.id, comment: editCommentId)
            .receive(on: DispatchQueue.main)
            .sink(
                receiveCompletion: { [weak self] value in
                    guard let self = self else { return }
                },
                receiveValue: { [weak self] receive in
                    guard let self = self else { return }
                    let i = self.comments.firstIndex(where: { e in
                        return e.id == self.editCommentId
                    })
                    self.comments.remove(at: i!)
                    self.article.commentCount! -= 1
                    self.dataSource = self.comments.map { value in
                        CommentRowViewModel(item: value, boardId: self.boardId, articleId: self.id)
                    }
                    self.clearComment()
            })
            .store(in: &disposables)
    }
    
    func deleteAnonymousComment() {
        communityFetcher.DeleteAnonymousComment(password: hashed(pw: password), article: article.id, comment: editCommentId)
            .receive(on: DispatchQueue.main)
            .sink(
                receiveCompletion: { [weak self] value in
                    guard let self = self else { return }
                },
                receiveValue: { [weak self] receive in
                    guard let self = self else { return }
                    let i = self.comments.firstIndex(where: { e in
                        return e.id == self.editCommentId
                    })
                    self.comments.remove(at: i!)
                    self.article.commentCount! -= 1
                    self.dataSource = self.comments.map { value in
                        CommentRowViewModel(item: value, boardId: self.boardId, articleId: self.id)
                    }
                    self.clearComment()
            })
            .store(in: &disposables)
    }
    
    func putComment() {
        communityFetcher.PutComment(token: token, article: article.id, content: content)
            .receive(on: DispatchQueue.main)
            .sink(
                receiveCompletion: { [weak self] value in
                    guard let self = self else { return }
                },
                receiveValue: { [weak self] receive in
                    guard let self = self else { return }
                    self.comments.append(receive as! C)
                    self.article.commentCount! += 1
                    self.dataSource = self.comments.map { value in
                        CommentRowViewModel(item: value, boardId: self.boardId, articleId: self.id)
                    }
                    self.objectWillChange.send(self)
                    self.clearComment()
            })
            .store(in: &disposables)
    }
    
    func putAnonymousComment() {
        communityFetcher.PutAnonymousComment(password: hashed(pw: password), article: article.id, nickname: tempNickname, content: content)
            .receive(on: DispatchQueue.main)
            .sink(
                receiveCompletion: { [weak self] value in
                    guard let self = self else { return }
                },
                receiveValue: { [weak self] receive in
                    guard let self = self else { return }
                    self.comments.append(receive as! C)
                    self.article.commentCount! += 1
                    self.dataSource = self.comments.map { value in
                        CommentRowViewModel(item: value, boardId: self.boardId, articleId: self.id)
                    }
                    self.objectWillChange.send(self)
                    self.clearComment()
            })
            .store(in: &disposables)
    }
    
    func updateComment() {
        communityFetcher.UpdateComment(token: token, article: article.id, comment: editCommentId, content: content)
            .receive(on: DispatchQueue.main)
            .sink(
                receiveCompletion: { [weak self] value in
                    guard let self = self else { return }
                },
                receiveValue: { [weak self] receive in
                    guard let self = self else { return }
                    let i = self.comments.firstIndex(where: { e in
                        return e.id == self.editCommentId
                    })
                    self.comments[i!] = receive as! C
                    self.dataSource = self.comments.map { value in
                        CommentRowViewModel(item: value, boardId: self.boardId, articleId: self.id)
                    }
                    self.clearComment()
            })
            .store(in: &disposables)
    }
    
    func updateAnonymousComment() {
        communityFetcher.UpdateAnonymousComment(password: hashed(pw: password), article: article.id, nickname: tempNickname, comment: editCommentId, content: content)
            .receive(on: DispatchQueue.main)
            .sink(
                receiveCompletion: { [weak self] value in
                    guard let self = self else { return }
                },
                receiveValue: { [weak self] receive in
                    guard let self = self else { return }
                    let i = self.comments.firstIndex(where: { e in
                        return e.id == self.editCommentId
                    })
                    self.comments[i!] = receive as! C
                    self.dataSource = self.comments.map { value in
                        CommentRowViewModel(item: value, boardId: self.boardId, articleId: self.id)
                    }
                    self.clearComment()
            })
            .store(in: &disposables)
    }
    
}
