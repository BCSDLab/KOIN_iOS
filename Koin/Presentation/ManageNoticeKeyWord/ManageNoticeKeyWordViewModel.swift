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
        case getMyKeyWord
    }
    enum Output {
        case updateKeyWord([NoticeKeyWordDTO])
    }
    
    private let outputSubject = PassthroughSubject<Output, Never>()
    private var subscriptions: Set<AnyCancellable> = []
    private let addNotificationKeyWordUseCase: AddNotificationKeyWordUseCase
    
    init(addNotificationKeyWordUseCase: AddNotificationKeyWordUseCase) {
        self.addNotificationKeyWordUseCase = addNotificationKeyWordUseCase
    }
  
    func transform(with input: AnyPublisher<Input, Never>) -> AnyPublisher<Output, Never> {
        input.sink { [weak self] input in
            switch input {
            case let .addKeyWord(keyWord):
                self?.addKeyWord(keyWord: keyWord)
            case .getMyKeyWord:
                self?.fetchMyKeyWord()
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
        
    }
}



