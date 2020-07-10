//
//  CommunityViewModel.swift
//  Koin
//
//  Created by 정태훈 on 2020/04/06.
//  Copyright © 2020 정태훈. All rights reserved.
//

import Foundation
import Combine
import PKHUD
import Firebase
import FirebaseFirestoreSwift

public extension Array where Element: Hashable {
    static func removeDuplicates(_ elements: [Element]) -> [Element] {
        var seen = Set<Element>()
        return elements.filter{ seen.insert($0).inserted }
    }
}

class CommunityViewModel<T: CommonArticle>: ObservableObject, Identifiable {
    @Published var dataSource: [CommunityRowViewModel<T>] = []
    
    var result = PassthroughSubject<[CommunityRowViewModel<T>], Never>()
    
    private let communityFetcher: CommunityFetchable
    
    private var disposables = Set<AnyCancellable>()
    
    var boardId: Int
    
    var page: Int
    
    @Published var block: [Int] = []
    
    @Published var progress: Bool = true
    
    init(communityFetcher: CommunityFetchable, boardId: Int, userId: Int) {
        self.communityFetcher = communityFetcher
        self.boardId = boardId
        self.page = 1
        if(T.self == Article.self) {
            self.loadBlockCommunity(userId: userId)
        } else {
            self.loadTempBlockCommunity(userId: userId)
        }
    }
    
    func loadBlockCommunity(userId: Int) {
        let userRef = Firestore.firestore().collection("Block").document("\(userId)")
        userRef.getDocument { (document, error) in
            if let document = document, document.exists {
                let data = document.data()?["Article"] as? [Int] ?? []
                self.block = data
            } else {
                print("not exist")
            }
        }
    }
    
    func loadTempBlockCommunity(userId: Int) {
        let userRef = Firestore.firestore().collection("Block").document("\(userId)")
        userRef.getDocument { (document, error) in
            if let document = document, document.exists {
                let data = document.data()?["TempArticle"] as? [Int] ?? []
                self.block = data
            } else {
                print("not exist")
            }
        }
    }
    
    func fetchCommunity(){
            self.communityFetcher.CommunityList(boardId: self.boardId, page: 1)
                .map { response in
                    response.articles.map {
                        CommunityRowViewModel(item: $0 as! T)
                    }
            }
            .map(Array.removeDuplicates)
            .receive(on: DispatchQueue.main)
            .sink(
                receiveCompletion: { [weak self] value in
                    guard let self = self else { return }
                    switch value {
                        case .failure:
                            self.dataSource = []
                        case .finished:
                            break
                    }
                },
                receiveValue: { [weak self] community in
                    guard let self = self else { return }
                    for c in community {
                        if(!self.block.contains(c.id)) {
                            self.dataSource.append(c)
                        }
                    }
                    self.result.send(self.dataSource)
            })
                .store(in: &self.disposables)
    }
    
    func fetchTempCommunity() {
        communityFetcher.AnonymousCommunityList(page: 1)
            .map { response in
                response.articles.map {
                    CommunityRowViewModel(item: $0 as! T)
                }
        }
        .map(Array.removeDuplicates)
        .receive(on: DispatchQueue.main)
        .sink(
            receiveCompletion: { [weak self] value in
                guard let self = self else { return }
                switch value {
                    case .failure:
                        self.dataSource = []
                    case .finished:
                        break
                }
            },
            receiveValue: { [weak self] community in
                guard let self = self else { return }
                for c in community {
                    if(!self.block.contains(c.id)) {
                        self.dataSource.append(c)
                    }
                }
                self.result.send(self.dataSource)
                //self.dataSource = community
        })
            .store(in: &disposables)
    }
    
    func reloadCommunity() {
        page += 1
        communityFetcher.CommunityList(boardId: boardId, page: page)
            .map { response in
                response.articles.map {
                    CommunityRowViewModel(item: $0 as! T)
                }
        }
        .map(Array.removeDuplicates)
        .receive(on: DispatchQueue.main)
        .sink(
            receiveCompletion: { [weak self] value in
                guard let self = self else { return }
                switch value {
                    case .failure:
                    break
                    case .finished:
                        break
                }
            },
            receiveValue: { [weak self] community in
                guard let self = self else { return }
                for c in community {
                    if(!self.block.contains(c.id)) {
                        self.dataSource.append(c)
                    }
                }
                self.result.send(self.dataSource)
                //self.dataSource += community
        })
            .store(in: &disposables)
    }
    
    func reloadTempCommunity() {
        page += 1
        communityFetcher.AnonymousCommunityList(page: page)
            .map { response in
                response.articles.map {
                    CommunityRowViewModel(item: $0 as! T)
                }
        }
        .map(Array.removeDuplicates)
        .receive(on: DispatchQueue.main)
        .sink(
            receiveCompletion: { [weak self] value in
                guard let self = self else { return }
                switch value {
                    case .failure:
                        break
                    case .finished:
                        break
                }
            },
            receiveValue: { [weak self] community in
                guard let self = self else { return }
                for c in community {
                    if(!self.block.contains(c.id)) {
                        self.dataSource.append(c)
                    }
                }
                self.result.send(self.dataSource)
                //self.dataSource += community
        })
            .store(in: &disposables)
    }
    
}
