//
//  CallVanDataViewModel.swift
//  koin
//
//  Created by 홍기정 on 3/10/26.
//

import Foundation
import Combine

final class CallVanDataViewModel: ViewModelProtocol {
    
    enum Output {
        case update(CallVanData)
    }
    enum Input {
        case viewDidLoad
    }
    
    // MARK: - Properties
    let postId: Int
    private let fetchCallVanDataUseCase: FetchCallVanDataUseCase
    private let outputSubject = PassthroughSubject<Output, Never>()
    private var subscriptions: Set<AnyCancellable> = []
    
    // MARK: - Initializer
    init(
        postId: Int,
        fetchCallVanDataUseCase: FetchCallVanDataUseCase
    ) {
        self.postId = postId
        self.fetchCallVanDataUseCase = fetchCallVanDataUseCase
    }
    
    // MARK: - Public
    func transform(with input: AnyPublisher<Input, Never>) -> AnyPublisher<Output, Never> {
        input.sink { [weak self] input in
            guard let self else { return }
            switch input {
            case .viewDidLoad:
                fetchData()
            }
        }.store(in: &subscriptions)
        return outputSubject.eraseToAnyPublisher()
    }
}

extension CallVanDataViewModel {
    
    private func fetchData() {
        fetchCallVanDataUseCase.execute(postId: postId).sink(
            receiveCompletion: { _ in },
            receiveValue: { [weak self] callVanData in
                self?.outputSubject.send(.update(callVanData))
            }
        ).store(in: &subscriptions)
    }
}
