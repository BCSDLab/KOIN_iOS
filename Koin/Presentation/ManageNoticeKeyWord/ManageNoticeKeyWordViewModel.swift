//
//  ManageNoticeKeyWordViewModel.swift
//  koin
//
//  Created by JOOMINKYUNG on 8/23/24.
//

import Alamofire
import Combine
import Foundation

final class ManageNoticeKeyWordViewModel: ViewModelProtocol {
    enum Input {
        case addKeyWord(keyWord: String)
        case deleteKeyWord(keyWord: NoticeKeyWordDTO)
        case getMyKeyWord
        case changeNotification(isOn: Bool)
        case fetchSubscription
    }
    enum Output {
        case updateKeyWord([NoticeKeyWordDTO])
        case updateRecommendedKeyWord([String])
        case showLoginModal
        case updateSwitch(isOn: Bool)
        case keyWordIsIllegal(addKeyWordIllegalType)
    }
    
    enum addKeyWordIllegalType {
        case isDuplicated
        case isNotCharPredicate
        case exceedNumber
    }
    
    private let outputSubject = PassthroughSubject<Output, Never>()
    private var subscriptions: Set<AnyCancellable> = []
    private let addNotificationKeyWordUseCase: AddNotificationKeyWordUseCase
    private let deleteNotificationKeyWordUseCase: DeleteNotificationKeyWordUseCase
    private let fetchNotificationKeyWordUseCase: FetchNotificationKeyWordUseCase
    private let fetchRecommendedKeyWordUseCase: FetchRecommendedKeyWordUseCase
    private let changeNotiUseCase: ChangeNotiUseCase
    private let fetchNotiListUseCase: FetchNotiListUseCase
    
    init(addNotificationKeyWordUseCase: AddNotificationKeyWordUseCase, deleteNotificationKeyWordUseCase: DeleteNotificationKeyWordUseCase, fetchNotificationKeyWordUseCase: FetchNotificationKeyWordUseCase, fetchRecommendedKeyWordUseCase: FetchRecommendedKeyWordUseCase,
         changeNotiUseCase: ChangeNotiUseCase, fetchNotiListUseCase: FetchNotiListUseCase) {
        self.addNotificationKeyWordUseCase = addNotificationKeyWordUseCase
        self.deleteNotificationKeyWordUseCase = deleteNotificationKeyWordUseCase
        self.fetchNotificationKeyWordUseCase = fetchNotificationKeyWordUseCase
        self.fetchRecommendedKeyWordUseCase = fetchRecommendedKeyWordUseCase
        self.changeNotiUseCase = changeNotiUseCase
        self.fetchNotiListUseCase = fetchNotiListUseCase
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
            case let .changeNotification(isOn):
                self?.changeNotification(isOn: isOn)
            case .fetchSubscription:
                self?.fetchSubscription()
            }
        }.store(in: &subscriptions)
        return outputSubject.eraseToAnyPublisher()
    }
}

extension ManageNoticeKeyWordViewModel {
    private func addKeyWord(keyWord: String) {
        let requestModel = NoticeKeyWordDTO(id: nil, keyWord: keyWord)
        var isNotIllegal = true
        getMyKeyWord { [weak self] myKeyWords in
            guard let self = self else { return }
            if myKeyWords.contains(where: { $0.keyWord == keyWord }) {
                isNotIllegal = false
                self.outputSubject.send(.keyWordIsIllegal(.isDuplicated))
            }
            else if keyWord.count < 2 || keyWord.count > 10 {
                isNotIllegal = false
                self.outputSubject.send(.keyWordIsIllegal(.isNotCharPredicate))
            }
            else if myKeyWords.count > 9 {
                isNotIllegal = false
                self.outputSubject.send(.keyWordIsIllegal(.exceedNumber))
            }
            if isNotIllegal {
                self.addNotificationKeyWordUseCase.addNotificationKeyWordWithLogin(requestModel: requestModel).sink(receiveCompletion: { [weak self] completion in
                    if case let .failure(error) = completion {
                        Log.make().error("\(error)")
                        self?.addNotificationKeyWordUseCase.addNotificationKeyWordWithoutLogin(requestModel: keyWord)
                        self?.fetchMyKeyWord()
                    }
                }, receiveValue: { [weak self] result in
                    print("\(result) keyword is Registered")
                    self?.fetchMyKeyWord()
                }).store(in: &self.subscriptions)
            }
        }
    }
    
    private func fetchMyKeyWord() {
        getMyKeyWord { [weak self] myKeyWords in
            self?.outputSubject.send(.updateKeyWord(myKeyWords))
            self?.getRecommendedKeyWord(keyWords: myKeyWords)
        }
    }
    
    private func getMyKeyWord(completion: @escaping ([NoticeKeyWordDTO]) -> Void) {
        fetchNotificationKeyWordUseCase.fetchNotificationKeyWordWithLogin(keyWordForFilter: nil).sink(receiveCompletion: { [weak self] completionResult in
            if case let .failure(error) = completionResult {
                guard let self = self else { return }
                Log.make().error("\(error)")
                let result = self.fetchNotificationKeyWordUseCase.fetchNotificationKeyWordWithoutLogin()
                completion(result)
            }
        }, receiveValue: { keyWords in
            completion(keyWords)
        }).store(in: &subscriptions)
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
    
    private func fetchSubscription() {
        fetchNotiListUseCase.execute().sink { completion in
            if case let .failure(error) = completion {
                Log.make().error("\(error)")
            }
        } receiveValue: { [weak self] response in
            response.subscribes?.forEach {
                if $0.type == .articleKeyWord {
                    self?.outputSubject.send(.updateSwitch(isOn: $0.isPermit ?? false))
                }
            }
        }.store(in: &subscriptions)
    }
    
    private func getRecommendedKeyWord(keyWords: [NoticeKeyWordDTO]) {
        fetchRecommendedKeyWordUseCase.execute(filters: keyWords).sink(receiveCompletion: { completion in
            if case let .failure(error) = completion {
                Log.make().error("\(error)")
            }
        }, receiveValue: { keyWords in
            self.outputSubject.send(.updateRecommendedKeyWord(keyWords.keywords))
        }).store(in: &subscriptions)
    }
    
    private func changeNotification(isOn: Bool) {
        let httpMethod: Alamofire.HTTPMethod = isOn ? .post : .delete
        changeNotiUseCase.execute(method: httpMethod, type: .articleKeyWord).sink(receiveCompletion: { [weak self] completion in
            if case let .failure(error) = completion {
                Log.make().error("\(error)")
                self?.outputSubject.send(.showLoginModal)
            }
        }, receiveValue: { [weak self] response in
            self?.outputSubject.send(.updateSwitch(isOn: isOn))
        }).store(in: &subscriptions)
    }
}



