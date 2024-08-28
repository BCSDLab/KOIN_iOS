//
//  ManageNoticeKeyWordViewModel.swift
//  koin
//
//  Created by JOOMINKYUNG on 8/23/24.
//

import Combine
import Foundation

final class ManageNoticeKeyWordViewModel: ViewModelProtocol {
    enum keyWordType {
        case myKeyWord
        case recommendedKeyWord
    }
    
    enum Input {
        case addKeyWord(keyWord: NoticeKeyWordDTO)
        case deleteKeyWord(keyWord: NoticeKeyWordDTO)
        case getMyKeyWord
        case getRecommendedKeyWord
    }
    enum Output {
        case updateKeyWord([NoticeKeyWordDTO], keyWordType)
    }
    
    private let outputSubject = PassthroughSubject<Output, Never>()
    private var subscriptions: Set<AnyCancellable> = []
    private let addNotificationKeyWordUseCase: AddNotificationKeyWordUseCase
    private let deleteNotificationKeyWordUseCase: DeleteNotificationKeyWordUseCase
    private let fetchNotificationKeyWordUseCase: FetchNotificationKeyWordUseCase
    private let fetchRecommendedKeyWordUseCase: FetchRecommendedKeyWordUseCase
    
    init(addNotificationKeyWordUseCase: AddNotificationKeyWordUseCase, deleteNotificationKeyWordUseCase: DeleteNotificationKeyWordUseCase, fetchNotificationKeyWordUseCase: FetchNotificationKeyWordUseCase, fetchRecommendedKeyWordUseCase: FetchRecommendedKeyWordUseCase) {
        self.addNotificationKeyWordUseCase = addNotificationKeyWordUseCase
        self.deleteNotificationKeyWordUseCase = deleteNotificationKeyWordUseCase
        self.fetchNotificationKeyWordUseCase = fetchNotificationKeyWordUseCase
        self.fetchRecommendedKeyWordUseCase = fetchRecommendedKeyWordUseCase
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
            case .getRecommendedKeyWord:
                self?.getRecommendedKeyWord()
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
                self?.fetchMyKeyWord()
            }
        }, receiveValue: { [weak self] result in
            print("\(result) keyword is Registered")
            self?.fetchMyKeyWord()
        }).store(in: &subscriptions)
    }
    
    private func fetchMyKeyWord() {
        /*fetchNotificationKeyWordUseCase.fetchNotificationKeyWordUseCaseWithLogin().sink(receiveCompletion: { [weak self] completion in
         if case let .failure(error) = completion {
             guard let self = self else { return }
             Log.make().error("\(error)")
             let result = self.fetchNotificationKeyWordUseCase.fetchNotificationKeyWordUseCaseWithoutLogin()
             self.outputSubject.send(.updateKeyWord(result, .myKeyWord))
         }
     }, receiveValue: { [weak self] keyWords in
         self?.outputSubject.send(.updateKeyWord(keyWords, .myKeyWord))
     }).store(in: &subscriptions)*/
        let result = fetchNotificationKeyWordUseCase.fetchNotificationKeyWordUseCaseWithoutLogin()
        outputSubject.send(.updateKeyWord(result, .myKeyWord))
    }
    
    private func deleteMyKeyWord(keyWord: NoticeKeyWordDTO) {
        if let id = keyWord.id {
            deleteNotificationKeyWordUseCase.deleteNotificationKeyWordWithLogin(id: id)
                .sink(receiveCompletion: { completion in
                    if case let .failure(error) = completion {
                        Log.make().error("\(error)")
                    }
                }, receiveValue: { [weak self] result in
                    print("\(result) keyword is Deleted")
                    self?.fetchMyKeyWord()
                })
                .store(in: &subscriptions)
        } else {
            deleteNotificationKeyWordUseCase.deleteNotificationKeyWordWithoutLogin(keyWord: keyWord)
            fetchMyKeyWord()
        }
    }
    
    private func getRecommendedKeyWord() {
        fetchRecommendedKeyWordUseCase.execute().sink(receiveCompletion: { completion in
            if case let .failure(error) = completion {
                Log.make().error("\(error)")
            }
        }, receiveValue: { [weak self] keyWords in
            self?.outputSubject.send(.updateKeyWord(keyWords, .recommendedKeyWord))
        }).store(in: &subscriptions)
    }
}



