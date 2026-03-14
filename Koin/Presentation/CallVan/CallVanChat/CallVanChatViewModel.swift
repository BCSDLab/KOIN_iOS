//
//  CallVanChatViewModel.swift
//  koin
//
//  Created by 홍기정 on 3/9/26.
//

import Foundation
import Combine

final class CallVanChatViewModel: ViewModelProtocol {
    
    enum Input {}
    enum Output {}
    
    private let outputSubject = PassthroughSubject<Output, Never>()
    private var subscriptions: Set<AnyCancellable> = []
    let postId: Int
    
    init(postId: Int) {
        self.postId = postId
    }
    
    func transform(with input: AnyPublisher<Input, Never>) -> AnyPublisher<Output, Never> {
        input.sink { [weak self] input in
            guard let self else { return }
            switch input {
                
            }
        }.store(in: &subscriptions)
        return outputSubject.eraseToAnyPublisher()
    }
}
