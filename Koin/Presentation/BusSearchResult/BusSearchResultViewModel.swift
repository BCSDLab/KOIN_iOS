//
//  BusSearchResultViewModel.swift
//  koin
//
//  Created by JOOMINKYUNG on 11/10/24.
//

import Combine

final class BusSearchResultViewModel: ViewModelProtocol {
    enum Input {
        case getDatePickerData
    }
    enum Output {
        case updateDatePickerData(([[String]], [String]))
    }
    
    private let outputSubject = PassthroughSubject<Output, Never>()
    private let fetchDatePickerDataUseCase: FetchKoinPickerDataUseCase
    private var subscriptions: Set<AnyCancellable> = []
    
    init(fetchDatePickerDataUseCase: FetchKoinPickerDataUseCase) {
        self.fetchDatePickerDataUseCase = fetchDatePickerDataUseCase
    }
    
    func transform(with input: AnyPublisher<Input, Never>) -> AnyPublisher<Output, Never> {
        input.sink { [weak self] input in
            switch input {
            case .getDatePickerData:
                self?.getDatePickerData()
            }
        }.store(in: &subscriptions)
        return outputSubject.eraseToAnyPublisher()
    }
}

extension BusSearchResultViewModel {
    private func getDatePickerData() {
        let data = fetchDatePickerDataUseCase.execute()
        outputSubject.send(.updateDatePickerData(data))
    }
}

