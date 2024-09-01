//
//  NoticeSearchViewModel.swift
//  koin
//
//  Created by JOOMINKYUNG on 8/23/24.
//

import Combine
import Foundation

final class NoticeSearchViewModel: ViewModelProtocol {
    
    enum Input {
        case getHotKeyWord(Int)
    }
    enum Output {
        case updateHotKeyWord(keyWords: [String])
    }
    
    private let outputSubject = PassthroughSubject<Output, Never>()
    private var subscriptions: Set<AnyCancellable> = []
    private let fetchHotKeyWordUseCase: FetchHotSearchingKeyWordUseCase
  
    init(fetchHotKeyWordUseCase: FetchHotSearchingKeyWordUseCase) {
        self.fetchHotKeyWordUseCase = fetchHotKeyWordUseCase
    }
    
    func transform(with input: AnyPublisher<Input, Never>) -> AnyPublisher<Output, Never> {
        input.sink { [weak self] input in
            switch input {
            case let .getHotKeyWord(count):
                self?.getHotKeyWord(count: count)
            }
        }.store(in: &subscriptions)
        return outputSubject.eraseToAnyPublisher()
    }
}

extension NoticeSearchViewModel {
    private func getHotKeyWord(count: Int) {
        fetchHotKeyWordUseCase.execute(count: count).sink(receiveCompletion: { completion in
            if case let .failure(error) = completion {
                Log.make().error("\(error)")
            }
        }, receiveValue: { [weak self] keyWords in
            self?.outputSubject.send(.updateHotKeyWord(keyWords: keyWords))
        }).store(in: &subscriptions)
    }
}


