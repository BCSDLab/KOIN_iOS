//
//  ManageNoticeKeyWordViewModel.swift
//  koin
//
//  Created by JOOMINKYUNG on 8/23/24.
//

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
        case keywordIsIllegal(String)
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
        getMyKeyword { [weak self] myKeywords in
            guard let self = self else { return }
            self.addNotificationKeywordUseCase
                .execute(keyword: requestModel, myKeywords: myKeywords)
                .receive(on: DispatchQueue.main)
                .throttle(for: .milliseconds(400), scheduler: RunLoop.main, latest: true)
                .sink(receiveCompletion: { [weak self] completion in
                if case let .failure(error) = completion {
                    Log.make().error("\(error)")
                    self?.fetchMyKeyword()
                }
            }, receiveValue: { [weak self] _, addKeywordResult in
                switch addKeywordResult {
                case .exceedNumber:
                    self?.outputSubject.send(.keywordIsIllegal("키워드는 최대 10개까지 추가할 수 있습니다."))
                case .notInRange:
                    self?.outputSubject.send(.keywordIsIllegal("키워드는 2글자에서 10글자 사이어야 합니다."))
                case .sameKeyword:
                    self?.outputSubject.send(.keywordIsIllegal("이미 같은 키워드가 존재합니다."))
                case .success:
                    self?.fetchMyKeyword()
                }
            }).store(in: &self.subscriptions)
        
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
        changeNotiUseCase.execute(method: isOn ? .post : .delete, type: .articleKeyWord).sink(receiveCompletion: { [weak self] completion in
            if case let .failure(error) = completion {
                Log.make().error("\(error)")
                self?.outputSubject.send(.showLoginModal)
            }
        }, receiveValue: { [weak self] response in
            self?.outputSubject.send(.updateSwitch(isOn: isOn))
        }).store(in: &subscriptions)
    }
}



