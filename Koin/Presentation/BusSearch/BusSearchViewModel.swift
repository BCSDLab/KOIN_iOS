//
//  BusSearchViewModel.swift
//  koin
//
//  Created by JOOMINKYUNG on 11/10/24.
//

import Combine

final class BusSearchViewModel: ViewModelProtocol {
    enum Input {
       
    }
    
    enum Output {
       
    }
    
    private let outputSubject = PassthroughSubject<Output, Never>()
    private var subscriptions: Set<AnyCancellable> = []
    
    func transform(with input: AnyPublisher<Input, Never>) -> AnyPublisher<Output, Never> {
        input.sink { [weak self] input in
           
        }.store(in: &subscriptions)
        return outputSubject.eraseToAnyPublisher()
    }
}

extension BusSearchViewModel {
    
    
}
