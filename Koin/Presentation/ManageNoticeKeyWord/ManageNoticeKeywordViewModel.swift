//
//  ManageNoticeKeyWordViewModel.swift
//  koin
//
//  Created by JOOMINKYUNG on 8/23/24.
//

import Alamofire
import Combine
import Foundation

final class ManageNoticeKeywordViewModel: ViewModelProtocol {
    enum Input {
        case addKeyword(keyword: String)
        case deleteKeyword(keyword: NoticeKeywordDTO)
        case getMyKeyword
        case changeNotification(isOn: Bool)
        case fetchSubscription
    }
    enum Output {
        case updateKeyword([NoticeKeywordDTO])
        case updateRecommendedKeyword([String])
        case showLoginModal
        case updateSwitch(isOn: Bool)
        case keywordIsIllegal(addKeyWordIllegalType)
    }
    
    enum addKeyWordIllegalType {
        case isDuplicated
        case isNotCharPredicate
        case exceedNumber
    }
    
    private let outputSubject = PassthroughSubject<Output, Never>()
    private var subscriptions: Set<AnyCancellable> = []
    private let addNotificationKeywordUseCase: AddNotificationKeywordUseCase
    private let deleteNotificationKeywordUseCase: DeleteNotificationKeywordUseCase
    private let fetchNotificationKeywordUseCase: FetchNotificationKeywordUseCase
    private let fetchRecommendedKeywordUseCase: FetchRecommendedKeywordUseCase
    private let changeNotiUseCase: ChangeNotiUseCase
    private let fetchNotiListUseCase: FetchNotiListUseCase
    
    init(addNotificationKeywordUseCase: AddNotificationKeywordUseCase, deleteNotificationKeywordUseCase: DeleteNotificationKeywordUseCase, fetchNotificationKeywordUseCase: FetchNotificationKeywordUseCase, fetchRecommendedKeywordUseCase: FetchRecommendedKeywordUseCase,
         changeNotiUseCase: ChangeNotiUseCase, fetchNotiListUseCase: FetchNotiListUseCase) {
        self.addNotificationKeywordUseCase = addNotificationKeywordUseCase
        self.deleteNotificationKeywordUseCase = deleteNotificationKeywordUseCase
        self.fetchNotificationKeywordUseCase = fetchNotificationKeywordUseCase
        self.fetchRecommendedKeywordUseCase = fetchRecommendedKeywordUseCase
        self.changeNotiUseCase = changeNotiUseCase
        self.fetchNotiListUseCase = fetchNotiListUseCase
    }
  
    func transform(with input: AnyPublisher<Input, Never>) -> AnyPublisher<Output, Never> {
        input.sink { [weak self] input in
            switch input {
            case let .addKeyword(keyword):
                self?.addKeyword(keyword: keyword)
            case .getMyKeyword:
                self?.fetchMyKeyword()
            case let .deleteKeyword(keyWord):
                self?.deleteMyKeyword(keyWord: keyWord)
            case let .changeNotification(isOn):
                self?.changeNotification(isOn: isOn)
            case .fetchSubscription:
                self?.fetchSubscription()
            }
        }.store(in: &subscriptions)
        return outputSubject.eraseToAnyPublisher()
    }
}

extension ManageNoticeKeywordViewModel {
    private func addKeyword(keyword: String) {
        let requestModel = NoticeKeywordDTO(id: nil, keyword: keyword)
        var isNotIllegal = true
        getMyKeyword { [weak self] myKeywords in
            guard let self = self else { return }
            if myKeywords.contains(where: { $0.keyword == keyword }) {
                isNotIllegal = false
                self.outputSubject.send(.keywordIsIllegal(.isDuplicated))
            }
            else if keyword.count < 2 || keyword.count > 10 {
                isNotIllegal = false
                self.outputSubject.send(.keywordIsIllegal(.isNotCharPredicate))
            }
            else if myKeywords.count > 9 {
                isNotIllegal = false
                self.outputSubject.send(.keywordIsIllegal(.exceedNumber))
            }
            if isNotIllegal {
                self.addNotificationKeywordUseCase.execute(keyword: requestModel).sink(receiveCompletion: { [weak self] completion in
                    if case let .failure(error) = completion {
                        Log.make().error("\(error)")
                        self?.fetchMyKeyword()
                    }
                }, receiveValue: { [weak self] result in
                    print("\(result) keyword is Registered")
                    self?.fetchMyKeyword()
                }).store(in: &self.subscriptions)
            }
        }
    }
    
    private func fetchMyKeyword() {
        getMyKeyword { [weak self] myKeywords in
            self?.outputSubject.send(.updateKeyword(myKeywords))
            self?.getRecommendedKeyword(keywords: myKeywords)
        }
    }
    
    private func getMyKeyword(completion: @escaping ([NoticeKeywordDTO]) -> Void) {
        fetchNotificationKeywordUseCase.execute().sink(receiveCompletion: { completionResult in
            if case let .failure(error) = completionResult {
                Log.make().error("\(error)")
            }
        }, receiveValue: { fetchkeywords in
            completion(fetchkeywords.0)
        }).store(in: &subscriptions)
    }
    
    private func deleteMyKeyword(keyWord: NoticeKeywordDTO) {
        deleteNotificationKeywordUseCase.execute(keyword: keyWord)
            .sink(receiveCompletion: { [weak self] completion in
                if case let .failure(error) = completion {
                    Log.make().error("\(error)")
                    self?.fetchMyKeyword()
                }
            }, receiveValue: { [weak self] result in
                print("\(result) keyword is Deleted")
                self?.fetchMyKeyword()
            })
            .store(in: &subscriptions)
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
    
    private func getRecommendedKeyword(keywords: [NoticeKeywordDTO]) {
        fetchRecommendedKeywordUseCase.execute(filters: keywords).sink(receiveCompletion: { completion in
            if case let .failure(error) = completion {
                Log.make().error("\(error)")
            }
        }, receiveValue: { keywords in
            self.outputSubject.send(.updateRecommendedKeyword(keywords.keywords))
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



