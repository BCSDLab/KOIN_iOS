//
//  FetchCallVanListUseCase.swift
//  koin
//
//  Created by 홍기정 on 3/5/26.
//

import Foundation
import Combine

protocol FetchCallVanListUseCase {
    func execute(request: CallVanListRequest) -> AnyPublisher<CallVanList, ErrorResponse>
}

final class DefaultFetchCallVanListUseCase: FetchCallVanListUseCase {
    
    private let repository: CallVanRepository
    
    init(repository: CallVanRepository) {
        self.repository = repository
    }
    
    func execute(request: CallVanListRequest) -> AnyPublisher<CallVanList, ErrorResponse> {
        repository.fetchCallVanList(request: request)
            .map {
                let posts = $0.posts.filter { [weak self] post in
                    guard let self else { return
                        false
                    }
                    if post.isJoined && post.isCompleted {
                        return !isMoreThanWeekAgo(date: post.date)
                    } else {
                        return post.mainState != nil
                    }
                }
                var list = $0
                list.posts = posts
                return list
            }
            .eraseToAnyPublisher()
    }
}

extension DefaultFetchCallVanListUseCase {
    
    private func isMoreThanWeekAgo(date: Date?) -> Bool {
        guard let date else {
            assert(false)
            return true
        }
        let weekAgo = Date(timeIntervalSinceNow: -60 * 60 * 24 * 7)
        if date < weekAgo {
            return true
        } else {
            return false
        }
    }
}
