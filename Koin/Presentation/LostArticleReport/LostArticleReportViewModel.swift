//
//  LostArticleReportViewModel.swift
//  koin
//
//  Created by 김나훈 on 1/9/25.
//

import Combine

final class LostArticleReportViewModel: ViewModelProtocol {
    
    // MARK: - Input
    
    enum Input {
      
    }
    
    // MARK: - Output
    
    enum Output {
      
    }
    
    // MARK: - Properties
    
    private let outputSubject = PassthroughSubject<Output, Never>()
    private var subscriptions: Set<AnyCancellable> = []

    // MARK: - Initialization
    
    init() {
    }
    
    func transform(with input: AnyPublisher<Input, Never>) -> AnyPublisher<Output, Never> {
        input.sink { [weak self] input in
            switch input {
            }
        }.store(in: &subscriptions)
        return outputSubject.eraseToAnyPublisher()
    }
    
}

extension LostArticleReportViewModel {
    
    
}
