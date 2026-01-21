//
//  LostItemListViewModel.swift
//  koin
//
//  Created by 홍기정 on 1/17/26.
//

import Foundation
import Combine

final class LostItemListViewModel {
    
    enum Input {
        case checkLogin
        case loadList
        case loadMoreList
        case updateTitle(title: String?)
    }
    enum Output {
        case updateList([LostItemListData])
        case appendList([LostItemListData])
        case presentPostType
        case showLogin
        case resetList
    }
    
    // MARK: - Properties
    private let checkLoginUseCase: CheckLoginUseCase
    private let fetchLostItemItemUseCase: FetchLostItemListUseCase
    
    private let outputSubject = PassthroughSubject<Output, Never>()
    private var subscription: Set<AnyCancellable> = []
    var filterState = FetchLostItemListRequest()
    
    
    // MARK: - Initializer
    init(checkLoginUseCase: CheckLoginUseCase, fetchLostItemItemUseCase: FetchLostItemListUseCase) {
        self.checkLoginUseCase = checkLoginUseCase
        self.fetchLostItemItemUseCase = fetchLostItemItemUseCase
    }
    
    func transform(with input: AnyPublisher<Input, Never>) -> AnyPublisher<Output, Never> {
        input.sink { [weak self] input in
            guard let self else { return }
            switch input {
            case .loadList:
                self.loadList()
            case .loadMoreList:
                self.loadMoreList()
            case .checkLogin:
                self.checkLogin()
            case .updateTitle(let title):
                self.updateTitle(title)
            }
        }.store(in: &subscription)
        return outputSubject.eraseToAnyPublisher()
    }
}

extension LostItemListViewModel {
    
    private func loadList() {
        fetchLostItemItemUseCase.execute(requestModel: filterState).sink(
            receiveCompletion: { _ in },
            receiveValue: { [weak self] lostItemList in
                guard let self else { return }
                self.outputSubject.send(.updateList(lostItemList.articles))
            }
        ).store(in: &subscription)
    }
    
    private func loadMoreList() {
        filterState.page += 1
        
        fetchLostItemItemUseCase.execute(requestModel: filterState).sink(
            receiveCompletion: { _ in },
            receiveValue: { [weak self] lostItemList in
                guard let self, self.filterState.page == lostItemList.currentPage else {
                    return
                }
                self.outputSubject.send(.appendList(lostItemList.articles))
            }
        ).store(in: &subscription)
    }
    
    private func checkLogin() {
        checkLoginUseCase.execute().sink(
            receiveCompletion: { _ in},
            receiveValue: { [weak self] loggedIn in
                if loggedIn {
                    self?.outputSubject.send(.presentPostType)
                } else {
                    self?.outputSubject.send(.showLogin)
                }
            }
        ).store(in: &subscription)
    }
    
    private func updateTitle(_ title: String?) {
        guard filterState.title != title else {
            return
        }
        outputSubject.send(.resetList)
        
        if let title, !title.trimmingCharacters(in: .whitespaces).isEmpty {
            filterState.title = title
        } else {
            filterState.title = nil
        }
        filterState.page = 1
        
        fetchLostItemItemUseCase.execute(requestModel: filterState).sink(
            receiveCompletion: { _ in },
            receiveValue: { [weak self] lostItemList in
                self?.outputSubject.send(.updateList(lostItemList.articles))
            }
        ).store(in: &subscription)
    }
}
