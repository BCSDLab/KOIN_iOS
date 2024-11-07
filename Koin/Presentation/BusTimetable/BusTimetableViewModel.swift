//
//  BusTimetableViewModel.swift
//  koin
//
//  Created by JOOMINKYUNG on 2024/04/03.
//
import Combine
import Foundation

final class BusTimetableViewModel: ViewModelProtocol {
    private let outputSubject = PassthroughSubject<Output, Never>()
    
    enum Input {
        
    }

    enum Output {
        
    }
    
    func transform(with input: AnyPublisher<Input, Never>) -> AnyPublisher<Output, Never> {
        return outputSubject.eraseToAnyPublisher()
    }
}
