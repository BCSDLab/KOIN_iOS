//
//  NoticeDataViewModel.swift
//  koin
//
//  Created by JOOMINKYUNG on 8/19/24.
//

import Combine
import Foundation

final class NoticeDataViewModel: ViewModelProtocol {
    
    enum Input {
      
    }
    enum Output {
      
    }
    
    private let outputSubject = PassthroughSubject<Output, Never>()
    private var subscriptions = Set<AnyCancellable>()

    func transform(with input: AnyPublisher<Input, Never>) -> AnyPublisher<Output, Never> {
        input.sink { [weak self] input in
           
        }.store(in: &subscriptions)
        return outputSubject.eraseToAnyPublisher()
    }
}

extension NoticeDataViewModel {
   
}

