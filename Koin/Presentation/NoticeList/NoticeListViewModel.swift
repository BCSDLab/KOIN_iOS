//
//  NoticeListViewModel.swift
//  koin
//
//  Created by JOOMINKYUNG on 8/14/24.
//

import Combine
import Foundation

final class NoticeListViewModel: ViewModelProtocol {
    
    enum Input {
        case changeBoard(NoticeListType)
    }
    enum Output {
        case updateBoard([NoticeArticleDTO], NoticeListType)
    }
    
    private let outputSubject = PassthroughSubject<Output, Never>()
    private var subscriptions: Set<AnyCancellable> = []
    
    func transform(with input: AnyPublisher<Input, Never>) -> AnyPublisher<Output, Never> {
        input.sink { [weak self] input in
            switch input {
            case let .changeBoard(noticeListType):
                self?.changeBoard(noticeListType: noticeListType)
            }
        }.store(in: &subscriptions)
        return outputSubject.eraseToAnyPublisher()
    }
}

extension NoticeListViewModel {
    private func changeBoard(noticeListType: NoticeListType) {
        let testArticles = [NoticeArticleDTO(id: 0, boardID: 0, title: "aweawfe", content: "asdfaswe", nickname: "eafefs", hit: 2, createdAt: "aweaf", updatedAt: "awefwa")]
        outputSubject.send(.updateBoard(testArticles, noticeListType))
    }
}


