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
            return true
        }
        let calendar = Calendar(identifier: .gregorian)
        let todayStart = calendar.startOfDay(for: Date())
        guard let weekAgoStart = calendar.date(byAdding: .day, value: -7, to: todayStart) else {
            return true
        }
        if date < weekAgoStart {
            return true
        } else {
            return false
        }
    }
}
