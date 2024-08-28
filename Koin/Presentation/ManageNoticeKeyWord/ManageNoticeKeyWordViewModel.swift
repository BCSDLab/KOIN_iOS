//
//  ManageNoticeKeyWordViewModel.swift
//  koin
//
//  Created by JOOMINKYUNG on 8/23/24.
//

import Combine
import Foundation

final class ManageNoticeKeyWordViewModel: ViewModelProtocol {
    
    enum Input {
        case addKeyWord(keyWord: NoticeKeyWordDTO)
        case deleteKeyWord(keyWord: NoticeKeyWordDTO)
        case getMyKeyWord
    }
    enum Output {
        case updateKeyWord([NoticeKeyWordDTO])
    }
    
    private let outputSubject = PassthroughSubject<Output, Never>()
    private var subscriptions: Set<AnyCancellable> = []
    private let addNotificationKeyWordUseCase: AddNotificationKeyWordUseCase
    private let deleteNotificationKeyWordUseCase: DeleteNotificationKeyWordUseCase
    private let fetchNotificationKeyWordUsecase: FetchNotificationKeyWordUseCase
    
    init(addNotificationKeyWordUseCase: AddNotificationKeyWordUseCase, deleteNotificationKeyWordUseCase: DeleteNotificationKeyWordUseCase, fetchNotificationKeyWordUseCase: FetchNotificationKeyWordUseCase) {
        self.addNotificationKeyWordUseCase = addNotificationKeyWordUseCase
        self.deleteNotificationKeyWordUseCase = deleteNotificationKeyWordUseCase
        self.fetchNotificationKeyWordUsecase = fetchNotificationKeyWordUseCase
    }
  
    func transform(with input: AnyPublisher<Input, Never>) -> AnyPublisher<Output, Never> {
        input.sink { [weak self] input in
            switch input {
            case let .addKeyWord(keyWord):
                self?.addKeyWord(keyWord: keyWord)
            case .getMyKeyWord:
                self?.fetchMyKeyWord()
            case let .deleteKeyWord(keyWord):
                self?.deleteMyKeyWord(keyWord: keyWord)
            }
        }.store(in: &subscriptions)
        return outputSubject.eraseToAnyPublisher()
    }
}

extension ManageNoticeKeyWordViewModel {
    private func addKeyWord(keyWord: NoticeKeyWordDTO) {
        addNotificationKeyWordUseCase.addNotificationKeyWordWithLogin(requestModel: keyWord).sink(receiveCompletion: { [weak self] completion in
            if case let .failure(error) = completion {
                Log.make().error("\(error)")
                self?.addNotificationKeyWordUseCase.addNotificationKeyWordWithoutLogin(requestModel: keyWord)
            }
        }, receiveValue: { result in
            print("\(result) keyword is Registered")
        }).store(in: &subscriptions)
    }
    
    private func fetchMyKeyWord() {
        fetchNotificationKeyWordUsecase.fetchNotificationKeyWordUseCaseWithLogin().sink(receiveCompletion: { [weak self] completion in
            if case let .failure(error) = completion {
                guard let self = self else { return }
                Log.make().error("\(error)")
                let result = self.fetchNotificationKeyWordUsecase.fetchNotificationKeyWordUseCaseWithoutLogin()
                self.outputSubject.send(.updateKeyWord(result))
            }
        }, receiveValue: { [weak self] keyWords in
            self?.outputSubject.send(.updateKeyWord(keyWords))
        }).store(in: &subscriptions)
    }
    
    private func deleteMyKeyWord(keyWord: NoticeKeyWordDTO) {
        guard let id = keyWord.id else { return }
        deleteNotificationKeyWordUseCase.deleteNotificationKeyWordWithLogin(id: id).sink(receiveCompletion: { [weak self] completion in
            if case let .failure(error) = completion {
                Log.make().error("\(error)")
                self?.deleteNotificationKeyWordUseCase.deleteNotificationKeyWordWithoutLogin(keyWord: keyWord)
            }
        }, receiveValue: { result in
            print("\(result) keyword is Deleted")
        }).store(in: &subscriptions)
    }
}



