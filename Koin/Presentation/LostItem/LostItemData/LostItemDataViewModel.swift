//
//  LostItemDataViewModel.swift
//  koin
//
//  Created by 홍기정 on 1/19/26.
//

import Foundation
import Combine

final class LostItemDataViewModel {
    
    enum Input {
        case loadData
        case loadList
        case loadMoreList
        case checkLogIn
        case changeState(Int)
        case deleteData
    }
    enum Output {
        case updateData(LostItemData)
        case updateList([LostItemListData])
        case appendList([LostItemListData])
        case navigateToChat
        case showLoginModal
        case showToast(String)
        case changeState
        case deletedData(Int)
        case popViewController
    }
    
    // MARK: - Properties
    private let checkLoginUseCase: CheckLoginUseCase
    private let fetchLostItemDataUseCase: FetchLostItemDataUseCase
    private let fetchLostItemListUseCase: FetchLostItemListUseCase
    private let changeLostItemStateUseCase: ChangeLostItemStateUseCase
    private let deleteLostItemUseCase: DeleteLostItemUseCase
    private let outputSubject = PassthroughSubject<Output, Never>()
    private var subscriptions: Set<AnyCancellable> = []
    let id: Int
    private var filterState = FetchLostItemListRequest(limit: 5)
    
    // MARK: - Initializer
    init(checkLoginUseCase: CheckLoginUseCase,
         fetchLostItemDataUseCase: FetchLostItemDataUseCase,
         fetchLostItemListUseCase: FetchLostItemListUseCase,
         changeLostItemStateUseCase: ChangeLostItemStateUseCase,
         deleteLostItemUseCase: DeleteLostItemUseCase,
         id: Int) {
        self.checkLoginUseCase = checkLoginUseCase
        self.fetchLostItemDataUseCase = fetchLostItemDataUseCase
        self.fetchLostItemListUseCase = fetchLostItemListUseCase
        self.changeLostItemStateUseCase = changeLostItemStateUseCase
        self.deleteLostItemUseCase = deleteLostItemUseCase
        self.id = id
    }
    
    func transform(with input: AnyPublisher<Input, Never>) -> AnyPublisher<Output, Never> {
        input.sink { [weak self] input in
            guard let self else { return }
            switch input {
            case .loadData:
                self.loadData()
            case .loadList:
                self.loadList()
            case .loadMoreList:
                self.loadMoreList()
            case .checkLogIn:
                self.checkLogin()
            case .changeState(let id):
                self.changeState(id)
            case .deleteData:
                self.deleteData()
            }
        }.store(in: &subscriptions)
        return outputSubject.eraseToAnyPublisher()
    }
}

extension LostItemDataViewModel {
    
    private func loadData() {
        fetchLostItemDataUseCase.execute(id: id).sink(
            receiveCompletion: { completion in
                if case .failure(let failure) = completion {
                    print(failure)
                }
            },
            receiveValue: { [weak self] lostItemData in
                self?.outputSubject.send(.updateData(lostItemData))
            }
        ).store(in: &subscriptions)
    }
    
    private func loadList() {
        fetchLostItemListUseCase.execute(requestModel: filterState).sink(
            receiveCompletion: { _ in },
            receiveValue: { [weak self] lostItemList in
                self?.outputSubject.send(.updateList(lostItemList.articles.filter { !$0.isReported }))
            }
        ).store(in: &subscriptions)
    }
    
    private func loadMoreList() {
        filterState.page += 1
        
        fetchLostItemListUseCase.execute(requestModel: filterState).sink(
            receiveCompletion: { _ in },
            receiveValue: { [weak self] lostItemList in
                guard let self, self.filterState.page == lostItemList.currentPage else {
                    return
                }
                self.outputSubject.send(.appendList(lostItemList.articles.filter { !$0.isReported }))
            }
        ).store(in: &subscriptions)
    }
    
    private func checkLogin() {
        checkLoginUseCase.execute().sink(
            receiveCompletion: { _ in },
            receiveValue: { [weak self] isLoggedIn in
                guard let self else { return }
                if isLoggedIn {
                    outputSubject.send(.navigateToChat)
                } else {
                    outputSubject.send(.showLoginModal)
                }
            }
        ).store(in: &subscriptions)
    }
    
    private func changeState(_ id: Int) {
        changeLostItemStateUseCase.execute(id: id).sink(
            receiveCompletion: { [weak self] completion in
                if case let .failure(error) = completion {
                    self?.outputSubject.send(.showToast(error.message))
                }
            },
            receiveValue: { [weak self] in
                self?.outputSubject.send(.changeState)
            }
        ).store(in: &subscriptions)
    }
    
    private func deleteData() {
        deleteLostItemUseCase.execute(id: id).sink(
            receiveCompletion: { _ in },
            receiveValue: { [weak self] in
                guard let self else { return }
                outputSubject.send(.popViewController)
                outputSubject.send(.deletedData(id))
            }
        ).store(in: &subscriptions)
    }
}
